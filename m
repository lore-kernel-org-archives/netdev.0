From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [Coverity] Untrusted user data in kernel
Date: Fri, 17 Dec 2004 17:31:05 +0100
Message-ID: <200412171731.05735.oliver@neukum.org>
References: <41C26DD1.7070006@trash.net> <41C2FF99.3020908@tmr.com> <Pine.LNX.4.61.0412171108340.4216@chaos.analogic.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-2"
Content-Transfer-Encoding: 7bit
Cc: Bill Davidsen <davidsen@tmr.com>, James Morris <jmorris@redhat.com>,
        Patrick McHardy <kaber@trash.net>, Bryan Fulton <bryan@coverity.com>,
        netdev@oss.sgi.com, netfilter-devel@lists.netfilter.org,
        linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-os@analogic.com
In-Reply-To: <Pine.LNX.4.61.0412171108340.4216@chaos.analogic.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


> > Are you saying that processes with capability don't make mistakes? This isn't 
> > a bug related to untrusted users doing privileged operations, it's a case of 
> > using unchecked user data.
> >
> 
> But isn't there always the possibility of "unchecked user data"?
> I can, as root, do `cp /dev/zero /dev/mem` and have the most
> spectacular crask you've evet seen. I can even make my file-
> systems unrecoverable.

Only if you have the capability for raw hardware access.
The same is true for the firmware interface. What other subsystems might
be dangerous?

	Regards
		Oliver
