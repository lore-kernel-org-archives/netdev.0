From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 2.6] update to network emulation QOS scheduler
Date: 08 Jul 2004 09:36:14 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1089293774.1349.118.camel@jzny.localdomain>
References: <20040701113312.43cfe6c5@dell_ss3.pdx.osdl.net>
	 <20040702134437.5891e998@dell_ss3.pdx.osdl.net>
	 <1088824432.1043.271.camel@jzny.localdomain>
	 <20040707111055.32ebb25b@dell_ss3.pdx.osdl.net>
	 <1089226667.1027.411.camel@jzny.localdomain>
	 <20040707135831.4c98dd51@dell_ss3.pdx.osdl.net>
	 <1089234699.1026.448.camel@jzny.localdomain>
	 <20040707142216.7c9763c3@dell_ss3.pdx.osdl.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, Catalin BOIE <util@deuroconsult.ro>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040707142216.7c9763c3@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


I have taken out lartc from the CC; it keeps bouncing emails back to me.

On Wed, 2004-07-07 at 17:22, Stephen Hemminger wrote:

> Actually, the problem only occurs if burst is set large (like 2mb).
> I think it gets stuck waiting for that much data.

Sounds like a bug. If you have the exact setup description i can chase
it. 
What about CBQ, HTB, H-FSC?
The other way to do it is actually put a router next to a localy
generated traffic. I have used this many times in the past
(a sample is at: ftp://ftp.isi.edu/in-notes/rfc2884.txt section 4.1)

cheers,
jamal
