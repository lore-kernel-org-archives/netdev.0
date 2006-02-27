From: "Jesse Brandeburg" <jesse.brandeburg@gmail.com>
Subject: Re: [2.4.32 - 2.6.15.4] e1000 - Fix mii interface
Date: Mon, 27 Feb 2006 11:26:12 -0800
Message-ID: <4807377b0602271126s39285884gd0e1c51c14b5d6a7@mail.gmail.com>
References: <9a8748490602260700s2e82a623mcf2d778aa109bb00@mail.gmail.com>
	 <01e101c63ae7$1b417990$2001a8c0@cortex>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Jesper Juhl" <jesper.juhl@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	cramerj@intel.com, john.ronciak@intel.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932073AbWB0T0O@vger.kernel.org>
To: "Paul Rolland" <rol@witbe.net>, "Jeff Garzik" <jgarzik@pobox.com>
In-Reply-To: <01e101c63ae7$1b417990$2001a8c0@cortex>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2/26/06, Paul Rolland <rol@witbe.net> wrote:
> Hello,
>
> > Ok, great, I was just wondering since I would have made one if you had
> > no plans to do so.
>
> Well, I was just waiting to make sure it was interesting for someone ;)
>
> Here is it, verified with tab and not spaces... but attached as my mailer
> is likely to cripple anything I try to inline...
>
> Signed-off-by: Paul Rolland <rol@as2917.net>

I've got an issue with this, as the same function is called in
e1000_ethtool.c.  I think the correct fix is to fix the caller in the
mii-tool case, but I am working on verifiying my assumptions.

In the meantime can you send the exact command you were having the problem with?
