From: Ed Wildgoose <lists@wildgooses.com>
Subject: Re: Re: [PATCH 2.6] update to network emulation QOS scheduler
Date: Sat, 03 Jul 2004 14:32:17 +0100
Sender: lartc-admin@mailman.ds9a.nl
Message-ID: <40E6B561.4050200@wildgooses.com>
References: <20040701113312.43cfe6c5@dell_ss3.pdx.osdl.net> <20040702134437.5891e998@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, lartc@mailman.ds9a.nl
Return-path: <lartc-admin@mailman.ds9a.nl>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040702134437.5891e998@dell_ss3.pdx.osdl.net>
Errors-To: lartc-admin@mailman.ds9a.nl
List-Help: <mailto:lartc-request@mailman.ds9a.nl?subject=help>
List-Post: <mailto:lartc@mailman.ds9a.nl>
List-Subscribe: <http://mailman.ds9a.nl/mailman/listinfo/lartc>,
	<mailto:lartc-request@mailman.ds9a.nl?subject=subscribe>
List-Unsubscribe: <http://mailman.ds9a.nl/mailman/listinfo/lartc>,
	<mailto:lartc-request@mailman.ds9a.nl?subject=unsubscribe>
List-Archive: <http://mailman.ds9a.nl/pipermail/lartc/>
List-Id: netdev.vger.kernel.org


>Here is an enhancement to netem to do allow emulating lower speed 
>networks.  The resolution is close, but obviously limited by the
>granularity of timers and size of packets.
>  
>

Hi Stephen,

This looks extremely useful.

I have a need for a simulator for the Iridium Satellite phone network, 
this is at most 2,400 baud with perhaps 1 sec or more latency.  Do you 
expect this scheduler to be able to do this slow?

On a related note, for better accuracy I currently need a bit of 
stochastic variability on the latency, ie assume a 1 sec min delay, but 
also to vary that a little through time.  Have you considered adding 
that as a feature?

Thanks

Ed W

_______________________________________________
LARTC mailing list / LARTC@mailman.ds9a.nl
http://mailman.ds9a.nl/mailman/listinfo/lartc HOWTO: http://lartc.org/
