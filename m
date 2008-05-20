From: "Ramachandra K" <ramachandra.kuchimanchi@qlogic.com>
Subject: Re: [ofa-general] Re: [PATCH 10/13] QLogic VNIC: Driver Statistics
	collection
Date: Tue, 20 May 2008 22:22:50 +0530
Message-ID: <71d336490805200952k2c31b6abkfcf70ed7481a95d@mail.gmail.com>
References: <20080430171028.31725.86190.stgit@localhost.localdomain>
	<20080430172055.31725.70663.stgit@localhost.localdomain>
	<adabq37dwob.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amar.mudrankit@qlogic.com,
	general@lists.openfabrics.org, poornima.kamath@qlogic.com
To: "Roland Dreier" <rdreier@cisco.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <adabq37dwob.fsf@cisco.com>
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

On Fri, May 16, 2008 at 4:03 AM, Roland Dreier <rdreier@cisco.com> wrote:
>  > +#else       /*CONFIG_INIFINIBAND_VNIC_STATS*/
>  > +
>  > +static inline void vnic_connected_stats(struct vnic *vnic)
>  > +{
>  > +    ;
>  > +}
>
> there are an awful lot of stubs here.  Do you really expect anyone to
> set CONFIG_INFINIBAND_QLGC_VNIC_STATS=n?

Sorry, missed this comment from the first round of review. Yes, the default
behavior we want is to disable the statistics collection as some of the
statistics collection is in the data transfer path and hence this code
can add overheads. These statistics are more for performance debugging/tuning.

Regards,
Ram
