From: "Ramachandra K" <ramachandra.kuchimanchi@qlogic.com>
Subject: Re: [ofa-general] RE: [PATCH 11/13] QLogic VNIC: Driver utility file
	- implements various utility macros
Date: Thu, 1 May 2008 22:31:10 +0530
Message-ID: <71d336490805011001he7359dfw831470986d87b385@mail.gmail.com>
References: <20080430171028.31725.86190.stgit@localhost.localdomain>
	<20080430172126.31725.48554.stgit@localhost.localdomain>
	<20080501075816.1010ec3a@extreme>
	<C07C40DB2364324799506DE8FF12F8D8590EE1@EPEXCH1.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rdreier@cisco.com,
	"Amar Mudrankit \(Contractor - \)" <amar.mudrankit@qlogic.com>,
	general@lists.openfabrics.org,
	"Poornima Kamath \(Contractor - \)" <poornima.kamath@qlogic.com>
To: "Stephen Hemminger" <shemminger@vyatta.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <C07C40DB2364324799506DE8FF12F8D8590EE1@EPEXCH1.qlogic.org>
Content-Disposition: inline
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

Sorry for the resend. Original mail bounced from netdev.

On Thu, May 1, 2008 at 9:48 PM <ramachandra.kuchimanchi@qlogic.com> wrote:
> Stephen,
>
>
>  Stephen Hemminger [mailto:shemminger@vyatta.com] wrote:
>
>  > Ramachandra K <ramachandra.kuchimanchi@qlogic.com> wrote:
>
>  >> +#define is_power_of2(value) (((value) & ((value - 1))) == 0)
>  >> +#define ALIGN_DOWN(x, a)    ((x)&(~((a)-1)))
>
>  > In kernel.h already
>
>  Will fix this. Thanks.
>
>
>  >> +extern u32 vnic_debug;
>
>  > Use msg level macros instead?
>
>  I am sorry, I did not understand this comment.
>
>
>  > +
>  > +#define SYS_INFO(fmt, arg...)                                        \
>  > +      PRINT_CONDITIONAL(KERN_INFO,                           \
>  > +                        "SYS",                               \
>  > +                        (vnic_debug & DEBUG_SYS_INFO),       \
>  > +                        fmt, ##arg)
>  > +
>  > +#endif       /* VNIC_UTIL_H_INCLUDED */
>
>
>  > Many of these are already in standard macros pr_info, pr_err etc.
>
>  These macros are for providing a debug log level functionality through
>  the vnic_debug module parameter.
>
>  Regards,
>  Ram
