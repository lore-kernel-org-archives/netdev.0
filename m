From: jamal <hadi@cyberus.ca>
Subject: Re: dummy as IMQ replacement
Date: 31 Jan 2005 09:29:10 -0500
Message-ID: <1107181750.7847.198.camel@jzny.localdomain>
References: <1107123123.8021.80.camel@jzny.localdomain>
	 <200501311438.01118.hasso@estpak.ee>
	 <1107175673.7847.130.camel@jzny.localdomain>
	 <200501311502.56796.hasso@estpak.ee>
	 <20050131132819.GB31837@postel.suug.ch>
	 <1107179140.7840.157.camel@jzny.localdomain>
	 <20050131140630.GD31837@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Hasso Tepper <hasso@estpak.ee>, netdev@oss.sgi.com,
        Nguyen Dinh Nam <nguyendinhnam@gmail.com>,
        Remus <rmocius@auste.elnet.lt>, Andre Tomt <andre@tomt.net>,
        syrius.ml@no-log.org, Andy Furniss <andy.furniss@dsl.pipex.com>,
        Damion de Soto <damion@snapgear.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050131140630.GD31837@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2005-01-31 at 09:06, Thomas Graf wrote:
> > Yeah, that would fix it. Note however, that i am trying to highly
> > discourage use of iptables and i would rather let people who use
> > iptables to suffer;-> (sounds rude i know).  At some point i plan to
> > remove the dependency on iptables altogether.
> 
> Heh, I think it isn't rude, giving people a little clap to join
> the "good side" isn't that bad ;->
> 

Unfortunately killing it totaly would break all sorts of scripts.
Wish we could do this though ;->
Go ahead and push the patch to Dave even - I am just gonna look the
other way;->

> > So i am not sure whether i should encourage pushing of this patch or not ;->
> 
> I don't care that much, the patch is there, everyone can patch and
> distributions can pick it up. I agree that we should remove the
> dependency on iptables but I'd also like to see the dependency on the
> action bits to go away at the same time.

Agreed. 
The main reason not to use the iptables bits is performance; also its
just the wrong spot in the stack.

cheers,
jamal
