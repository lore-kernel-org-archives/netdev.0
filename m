From: Jamal Hadi Salim <hadi@znyx.com>
Subject: Re: patch: introduce simple actions
Date: 20 Mar 2005 15:17:34 -0500
Message-ID: <1111349853.1093.136.camel@jzny.localdomain>
References: <1111345551.1095.82.camel@jzny.localdomain>
	 <423DCD8C.6030100@trash.net> <1111347345.1094.98.camel@jzny.localdomain>
	 <423DD5E6.2020708@trash.net>
Reply-To: hadi@znyx.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com,
        Thomas Graf <tgraf@suug.ch>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <423DD5E6.2020708@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 2005-03-20 at 14:58, Patrick McHardy wrote:
> Jamal Hadi Salim wrote:
> > On Sun, 2005-03-20 at 14:22, Patrick McHardy wrote:
> >
> >>One of the next things I wanted to do in this area was
> >>moving all the large inline functions to act_generic.c,
> >>so if possible I would prefer not to put these in a header
> >>file.
> > 
> > These are small functions. Take a look at the simple action i attached.
> > If you can give me the same functionality and still move things
> > de_inlined to act_generic.c i would be fine with it.
> 
> The functions are not inlined anyway, so the question is whether any
> #define magic is done as with pkt_act.h, otherwise there is no reason
> to have them in a header file. Looking at your patch, it seems
> tc_defact.h uses the redefined pkt_act.h functions, so it does need to
> be in a header file, but frankly, I find this horrible. The patch
> doesn't conflict with cleanup of pkt_act.h, but it means more work when
> doing it, so I think this is what should be done first. Especially
> since this is only an example, not useful for users, but it will be
> possibly used to create more actions that also need to be changed
> afterwards.

Unfortunately code "augmentation"( as opposed to inheritance - cant
think of a better word) is much easier to do this way. The benefit of it
is the user gets a very simple programming interface - which is the main
reason this was written to begin with. The standard interface exists,
and more versed people or someone wanting to write something complex can
go that path. At some point i would like to document all this stuff.

How about this:
I submit this patch (with Thomas cleanup) and the simple action. I will
hold onto the 4 other actions i already have some of them complete until
you get around to moving things around and then i will redo them to
conform. This gets it off my back and we dont have any miscommunication
of what you are trying to do. sounds fair?

cheers,
jamal
