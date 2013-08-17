From: Alexander Shiyan <shc_work@mail.ru>
Subject: Re: [PATCH RESEND] can: mcp251x: Replace power callbacks with
 regulator API
Date: Sat, 17 Aug 2013 08:30:14 +0400
Message-ID: <20130817083014.a01144051b158c34ec7dd9d9@mail.ru>
References: <1375963227-6468-1-git-send-email-shc_work@mail.ru>
 <52049C44.6030902@pengutronix.de> <520EDDA8.6050309@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Russell King <linux@arm.linux.org.uk>, netdev@vger.kernel.org,
 linux-can@vger.kernel.org, Marc Kleine-Budde <mkl@pengutronix.de>,
 linux-arm-kernel@lists.infradead.org, Eric Miao <eric.y.miao@gmail.com>,
 Wolfgang Grandegger <wg@grandegger.com>
To: Haojian Zhuang <haojian.zhuang@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <520EDDA8.6050309@gmail.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Sat, 17 Aug 2013 10:19:20 +0800
Haojian Zhuang <haojian.zhuang@gmail.com> wrote:

> On 08/09/2013 03:37 PM, Marc Kleine-Budde wrote:
> > On 08/08/2013 02:00 PM, Alexander Shiyan wrote:
> >> Signed-off-by: Alexander Shiyan <shc_work@mail.ru>
> >> ---
> >>   arch/arm/mach-pxa/icontrol.c         |  3 --
> >>   arch/arm/mach-pxa/zeus.c             | 46 ++++++++++----------
> >
> > What's pxa's status of DT conversion? Do you (still) accept patches to
> > board files?
> >
> > Marc
> >
> 
> Since DT conversion isn't finished, I still accept the board files.
> But this patch should be split into two parts. One is for pxa, and the
> other one is for net.

Patch cannot be splitted because this can create hole which break git-bisect.

In any case, I want to create a v2 with a more detailed description, and I
have a supplementary question for the CAN subsystem maintainers.
"Transciever power" is not used by any of the boards, can we remove it
completely? This will greatly simplify driver.
Thanks.

-- 
Alexander Shiyan <shc_work@mail.ru>
