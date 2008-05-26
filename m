From: "Ramachandra K" <ramachandra.kuchimanchi@qlogic.com>
Subject: Re: [ofa-general] Re: [PATCH v2 12/13] QLogic VNIC: Driver Kconfig
	and Makefile.
Date: Mon, 26 May 2008 13:07:28 +0530
Message-ID: <71d336490805260037y4c45abd5lccd5dbadebd84eb8@mail.gmail.com>
References: <20080519102843.12355.832.stgit@localhost.localdomain>
	<20080519103730.12355.14730.stgit@localhost.localdomain>
	<adamyme57ir.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amar.mudrankit@qlogic.com,
	general@lists.openfabrics.org, poornima.kamath@qlogic.com
To: "Roland Dreier" <rdreier@cisco.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <adamyme57ir.fsf@cisco.com>
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

Roland,

On Mon, May 26, 2008 at 4:13 AM, Roland Dreier <rdreier@cisco.com> wrote:
>  > +config INFINIBAND_QLGC_VNIC_DEBUG
>  > +    bool "QLogic VNIC Verbose debugging"
>  > +    depends on INFINIBAND_QLGC_VNIC
>  > +    default n
>  > +    ---help---
>  > +      This option causes verbose debugging code to be compiled
>  > +      into the QLogic VNIC driver.  The output can be turned on via the
>  > +      vnic_debug module parameter.
>
> I think I mentioned this before, but... if you default this option to
> 'n', then all distributions will build your module with the option off.
> And if someone is having problems, they will be forced to rebuild their
> kernel to get debug output, which is a heavy burden for most users.

The debugging code is always compiled in and is controlled
at run time through vnic_debug module parameter.
INFINIBAND_QLGC_VNIC_DEBUG config option only controls verbose debugging
which adds some extra information in the debug statements (file name,
line number)
which we typically use for debug builds of the driver.  Even if this option is
set to 'n', users can still get all debug messages from the driver by using the
vnic_debug module parameter.

Regards,
Ram
