From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: ZyXEL GN650-T
Date: Fri, 12 Nov 2004 22:10:55 +0100
Message-ID: <20041112211055.GA346@electric-eye.fr.zoreil.com>
References: <20041107214427.20301.qmail@focomunicatii.ro> <20041107224803.GA29248@electric-eye.fr.zoreil.com> <20041109000006.GA14911@electric-eye.fr.zoreil.com> <20041109232510.GA5582@electric-eye.fr.zoreil.com> <20041110201010.18341.qmail@focomunicatii.ro> <20041110212835.GA23758@electric-eye.fr.zoreil.com> <20041110230853.GB23758@electric-eye.fr.zoreil.com> <20041111073754.27966.qmail@focomunicatii.ro> <20041111095102.GA2280@electric-eye.fr.zoreil.com> <20041112175911.24846.qmail@focomunicatii.ro>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: seby@focomunicatii.ro, linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
        alan@redhat.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: sebastian.ionita@focomunicatii.ro
Content-Disposition: inline
In-Reply-To: <20041112175911.24846.qmail@focomunicatii.ro>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

sebastian.ionita@focomunicatii.ro <sebastian.ionita@focomunicatii.ro> :
[...]
> Without vlan's it works but with vlan the behavier is just like with the 
> old drivers. Shoud I give some param's to the module if want to have vlans ?

I have modified the original patch. Does the network appliance allow you
to configure some specific VID, say 68, 1028 or 1092 ?

If yes, pick one and test the behavior of the three VID on the network adapter,
ideally within their own insmod, config up, ping (from host and remote),
config down and rmmod session.

Provided the issue is only a matter of ordering of the VID, something should
appear in the log/packet statistics when the VID overlap.

dmesg/kernel log messages as well as the serie of commands issued would be
welcome. bzip2 is your friend.

If the VID on the lan side is fixed for you, please send it so I'll see which
values on the network adapter could match (the values above are not sensitive
to endianness for instance).

A patch against vanilla 2.4.18-rc2 is available at:
http://www.fr.zoreil.com/people/francois/misc/20041112-2.4.28-rc2-via-velocity-backport.patch

--
Ueimor
