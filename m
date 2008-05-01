From: "Ramachandra K" <ramachandra.kuchimanchi@qlogic.com>
Subject: [ofa-general] [RESEND] RE: [PATCH 08/13] QLogic VNIC: sysfs
	interface implementation for the driver
Date: Thu, 1 May 2008 22:13:08 +0530
Message-ID: <71d336490805010943s79f01e01u9b4566165c4fba3f@mail.gmail.com>
References: <20080430171028.31725.86190.stgit@localhost.localdomain>
	<20080430171955.31725.7771.stgit@localhost.localdomain>
	<20080501075606.4963afa3@extreme>
	<C07C40DB2364324799506DE8FF12F8D8590EE0@EPEXCH1.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rdreier@cisco.com,
	"Amar Mudrankit \(Contractor - \)" <amar.mudrankit@qlogic.com>,
	general@lists.openfabrics.org,
	"Poornima Kamath \(Contractor - \)" <poornima.kamath@qlogic.com>
To: "Stephen Hemminger" <shemminger@vyatta.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <C07C40DB2364324799506DE8FF12F8D8590EE0@EPEXCH1.qlogic.org>
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

Sorry for the resend. Original mail got bounced from netdev.

On Thu, May 1, 2008 at 9:32 PM,  <ramachandra.kuchimanchi@qlogic.com> wrote:
>
> Stephen,
>
>
>  Stephen Hemminger [mailto:shemminger@vyatta.com] wrote:
>
>  >> On Wed, 30 Apr 2008 22:49:55 +0530
>  >> Ramachandra K <ramachandra.kuchimanchi@qlogic.com> wrote:
>
>  <snip>
>
>
>  >> +static match_table_t vnic_opt_tokens = {
>  >> +    {VNIC_OPT_IOC_GUID, "ioc_guid=%s"},
>  >> +    {VNIC_OPT_DGID, "dgid=%s"},
>  >> +    {VNIC_OPT_PKEY, "pkey=%x"},
>  >> +    {VNIC_OPT_NAME, "name=%s"},
>  >> +    {VNIC_OPT_INSTANCE, "instance=%d"},
>  >> +    {VNIC_OPT_RXCSUM, "rx_csum=%s"},
>  >> +    {VNIC_OPT_TXCSUM, "tx_csum=%s"},
>  >> +    {VNIC_OPT_HEARTBEAT, "heartbeat=%d"},
>  >> +    {VNIC_OPT_IOC_STRING, "ioc_string=\"%s"},
>  >> +    {VNIC_OPT_IB_MULTICAST, "ib_multicast=%s"},
>  >> +    {VNIC_OPT_ERR, NULL}
>  >> +};
>  >>
>
>  > NO
>  > 1. Most of this shouldn't be done via sysfs (rx_csum, tx_csum, ...)
>  > 2. Sysfs is one value per file not name=value
>
>  The VNIC driver needs multiple parameters (IOCGUID, DGID etc) from user space
>  to connect to the EVIC. For this the "name=value" mechanism is used for
>  a write-only sysfs file as an input method to the driver.
>
>  The driver follows the one value per file sysfs rule when it returns any data
>  with each readable file returning only a single value.
>
>  Regards,
>  Ram
