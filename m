From: Bart Van Assche <bart.vanassche@sandisk.com>
Subject: Re: [PATCH] Revert "netpoll: Fix extra refcount release in
 netpoll_cleanup()"
Date: Wed, 6 Apr 2016 07:13:45 -0700
Message-ID: <57051999.3080209@sandisk.com>
References: <20160405205822.24724.95522.stgit@bhelgaas-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Neil Horman <nhorman@redhat.com>,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Alexander Duyck <aduyck@mirantis.com>
To: Bjorn Helgaas <bhelgaas@google.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160405205822.24724.95522.stgit@bhelgaas-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/05/16 13:58, Bjorn Helgaas wrote:
> This reverts commit 543e3a8da5a4c453e992d5351ef405d5e32f27d7.
>
> Direct callers of __netpoll_setup() depend on it to set np->dev,
> so we can't simply move that assignment up to netpoll_stup().
>
> Reported-by: Bart Van Assche <bart.vanassche@sandisk.com>
> Signed-off-by: Bjorn Helgaas <bhelgaas@google.com>

Tested-by: Bart Van Assche <bart.vanassche@sandisk.com>

Thanks!

Bart.
