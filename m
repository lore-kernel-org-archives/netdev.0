From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 5/8] csiostor: Chelsio FCoE offload driver submission
 (sources part 5).
Date: Fri, 24 Aug 2012 11:27:34 -0700
Message-ID: <1345832854.32359.11.camel@joe2Laptop>
References: <1345760873-12101-1-git-send-email-naresh@chelsio.com>
	 <1345760873-12101-6-git-send-email-naresh@chelsio.com>
	 <1345751301.10190.75.camel@haakon2.linux-iscsi.org>
	 <5037BC94.1050201@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Nicholas A. Bellinger" <nab@linux-iscsi.org>,
	"JBottomley@parallels.com" <JBottomley@parallels.com>,
	"linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
	Dimitrios Michailidis <dm@chelsio.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Chethan Seshadri <chethan@chelsio.com>
To: Naresh Kumar Inna <naresh@chelsio.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <5037BC94.1050201@chelsio.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2012-08-24 at 23:10 +0530, Naresh Kumar Inna wrote:
> Is there a TRUE/FALSE define in a standard header file?

include/linux/stddef.h:
enum {
	false	= 0,
	true	= 1
};

> I see a lot of
> kernel code defining their own TRUE/FALSE.

Those should be changed eventually.

