From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH][2.6] de4x5 cleanup
Date: Sat, 30 Aug 2003 15:16:21 -0400
Sender: linux-net-owner@vger.kernel.org
Message-ID: <3F50F805.9090805@pobox.com>
References: <wrpad9r79g6.fsf@hina.wild-wind.fr.eu.org>	<3F50E3FD.1000703@pobox.com> <wrpn0dr55n1.fsf@hina.wild-wind.fr.eu.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, linux-net@vger.kernel.org,
	Maillist netdev <netdev@oss.sgi.com>
Return-path: <linux-net-owner@vger.kernel.org>
To: mzyngier@freesurf.fr
In-Reply-To: <wrpn0dr55n1.fsf@hina.wild-wind.fr.eu.org>
List-Id: netdev.vger.kernel.org

Marc Zyngier wrote:
>>>>>>"Jeff" == Jeff Garzik <jgarzik@pobox.com> writes:
> 
> 
> Jeff> It looks pretty good.  My big objection isn't the Space.c stuff
> Jeff> but de4x5 itself.  I had hoped it would be gone by now :) Oh
> Jeff> well, not your fault.
> 
> Well... I too, had hoped the tulip (and its dc21040 derivative)
> driver would be the only one. While it works nicely on modern stuff
> (2114[023]), it has some problems on a few of my test boxes (mostly
> Alphas with onboard 21040).

Well, 2.6 tulip intentionally doesn't work at all on 21040 and 21041 :) 
  That's what de2104x driver is for.  Can you give that a beating, and 
verify that it works for you?

I know that 2114x chips with sym phys still have some issues; jamal has 
created a patch that fixes that (mostly updates tulip with the latest 
Becker phy code from Donald's tulip.c), which in turn fixes some 2114x 
issues on alpha.


> And most of all, tulip doesn't support EISA :-).

If it meant I could kill de4x5, then I would be all for adding EISA 
support to tulip... :)

	Jeff



