From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC] meta ematch
Date: Sun, 16 Jan 2005 16:09:14 +0100
Message-ID: <20050116150914.GU26856@postel.suug.ch>
References: <20050108145457.GZ26856@postel.suug.ch> <1105363582.1041.162.camel@jzny.localdomain> <20050110211747.GA26856@postel.suug.ch> <1105394738.1085.63.camel@jzny.localdomain> <20050113174111.GP26856@postel.suug.ch> <41E6C3E5.2020908@trash.net> <20050113192047.GQ26856@postel.suug.ch> <41E71CC4.3020102@trash.net> <20050114151407.GR26856@postel.suug.ch> <1105887519.1097.597.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1105887519.1097.597.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1105887519.1097.597.camel@jzny.localdomain> 2005-01-16 09:58
> On Fri, 2005-01-14 at 10:14, Thomas Graf wrote:
> > 
> > Here's a revised patch. I fixed the numeric comparison issues and
> > added meta_obj instead of using meta_data to give a better impression
> > on the difference of a comparable object and meta data definitions.
> 
> I scanned the code very quickly; lets start with the big picture then i
> will send some more comments:
> Did i understand this correctly that a metamatch MUST have a lvalue +
> rvalue pair?

They MAY have bove.


> What if all i wanted to say was 
> ..
> ematch indev eth0
> 
The lvalue will be TCF_META_ID_INDEV and your rvalue will be
TCF_META_TYPE_VAR with "eth0" as payload(TCF_EM_META_RVALUE).
TCF_EM_META_LVALUE will be unused in this case.
