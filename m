From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [V2 PATCH 1/9] csiostor: Chelsio FCoE offload driver submission
 (sources part 1).
Date: Wed, 5 Sep 2012 09:23:26 -0700
Message-ID: <20120905092326.0a54226f@nehalam.linuxnetplumber.net>
References: <1346848442-4573-1-git-send-email-naresh@chelsio.com>
	<1346848442-4573-2-git-send-email-naresh@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: JBottomley@parallels.com, linux-scsi@vger.kernel.org,
	dm@chelsio.com, leedom@chelsio.com, netdev@vger.kernel.org,
	chethan@chelsio.com
To: Naresh Kumar Inna <naresh@chelsio.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <1346848442-4573-2-git-send-email-naresh@chelsio.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed,  5 Sep 2012 18:03:54 +0530
Naresh Kumar Inna <naresh@chelsio.com> wrote:

> +
> +/* FCoE Adapter types & its description */
> +static struct csio_adap_desc csio_fcoe_adapters[] = {

Tables like this should be const.
