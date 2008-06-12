From: "Ramachandra K" <ramachandra.kuchimanchi@qlogic.com>
Subject: Re: [ofa-general] [PATCH v4 00/14] QLogic VNIC Driver
Date: Thu, 12 Jun 2008 20:51:31 +0530
Message-ID: <71d336490806120821k3fe9f554l1a28dc55f204eadc@mail.gmail.com>
References: <20080610205633.11186.45499.stgit@dale>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: poornima.kamath@qlogic.com, amar.mudrankit@qlogic.com
To: rdreier@cisco.com, general@lists.openfabrics.org, netdev@vger.kernel.org
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20080610205633.11186.45499.stgit@dale>
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

On Wed, Jun 11, 2008 at 2:32 AM, Ramachandra K
<ramachandra.kuchimanchi@qlogic.com> wrote:
> Roland,
>
> This is the fourth round of QLogic Virtual NIC driver patch series for submission
> to 2.6.27 kernel. The series has been tested against your for-2.6.27 branch.
>
> Based on comments received on third series of patches, following fixes have
> been introduced in this series:
>
>        -  Single value per sysfs file created by QLogic VNIC Driver.
>        -  Documentation/ABI/testing/sysfs-class-infiniband-qlgc-vnic
>           describing the sysfs interface of the QLogic VNIC Driver.
>        -  Use of existing dev->stats instead of driver's private
>           vnic->stats.
>    -  Changing more generic name completion_callback_cleanup to
>           the one more driver specific - vnic_completion_cleanup
>    -  Removal of the field vnic->open
>    -  Minor Modifications to linked list manipulations.

Since the single value per sysfs file change has been implemented,
is the driver ready for merging or are there any more changes required
before the merge can happen ?

Regards,
Ram
