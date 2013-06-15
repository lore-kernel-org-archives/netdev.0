From: Timur Tabi <timur@tabi.org>
Subject: Re: [PATCH] MDIO: FSL_PQ_MDIO: Fix bug on incorrect offset of tbipa
 register
Date: Sat, 15 Jun 2013 17:57:18 -0500
Message-ID: <CAOZdJXVjdkMF5rpTVd9tnwCRDqXWtJTUAbywcuzoVehRrgPPsg@mail.gmail.com>
References: <1371041258-15298-1-git-send-email-ogabbay@advaoptical.com>
 <51B88EED.6090709@linutronix.de> <1371061871.18413.44@snotra>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Stef van Os <stef.van.os@prodrive.nl>,
 Oded Gabbay <ogabbay@advaoptical.com>, netdev@vger.kernel.org,
 Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
 Dongsheng.Wang@freescale.com, Timur Tabi <timur@tabi.org>,
 Paul Mackerras <paulus@samba.org>,
 "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
 David Miller <davem@davemloft.net>, lkml <linux-kernel@vger.kernel.org>,
 B38951@freescale.com
To: Scott Wood <scottwood@freescale.com>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <1371061871.18413.44@snotra>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev/>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: "Linuxppc-dev"
 <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
List-Id: netdev.vger.kernel.org

On Wed, Jun 12, 2013 at 1:31 PM, Scott Wood <scottwood@freescale.com> wrote:
>
> I'm not sure it's stable material if this is something that has never
> worked...
>
> The device tree binding will also need to be fixed to note the difference in
> "reg" between "fsl,gianfar-mdio" and "fsl-gianfar-tbi" -- and should give an
> example of the latter.

I don't remember how much I tested it, but I'm pretty sure that at
some of the suspect devices did work for me.  My goal was to maintain
compatibility with existing device trees, and just refactor the code
so that it's easier to read.
