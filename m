From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC] meta ematch
Date: 16 Jan 2005 09:58:40 -0500
Message-ID: <1105887519.1097.597.camel@jzny.localdomain>
References: <20050106194102.GW26856@postel.suug.ch>
	 <1105105511.1046.77.camel@jzny.localdomain>
	 <20050108145457.GZ26856@postel.suug.ch>
	 <1105363582.1041.162.camel@jzny.localdomain>
	 <20050110211747.GA26856@postel.suug.ch>
	 <1105394738.1085.63.camel@jzny.localdomain>
	 <20050113174111.GP26856@postel.suug.ch> <41E6C3E5.2020908@trash.net>
	 <20050113192047.GQ26856@postel.suug.ch> <41E71CC4.3020102@trash.net>
	 <20050114151407.GR26856@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050114151407.GR26856@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2005-01-14 at 10:14, Thomas Graf wrote:
> 
> Here's a revised patch. I fixed the numeric comparison issues and
> added meta_obj instead of using meta_data to give a better impression
> on the difference of a comparable object and meta data definitions.

I scanned the code very quickly; lets start with the big picture then i
will send some more comments:
Did i understand this correctly that a metamatch MUST have a lvalue +
rvalue pair?
What if all i wanted to say was 
..
ematch indev eth0

I only see one value there - does that become l or r? 

more comments coming - just ned some caffeine then i will stare.

cheers,
jamal
