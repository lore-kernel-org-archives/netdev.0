From: Sujith Manoharan <c_manoha@qca.qualcomm.com>
Subject: pull request: wireless 2012-06-22
Date: Sat, 23 Jun 2012 05:05:10 +0530
Message-ID: <20453.302.671438.533390@gargle.gargle.HOWL>
References: <20120622201716.GB13918@tuxdriver.com>
	<20452.64701.760819.559191@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Sujith Manoharan <c_manoha@qca.qualcomm.com>,
	<davem@davemloft.net>, <linux-wireless@vger.kernel.org>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20452.64701.760819.559191@gargle.gargle.HOWL>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sujith Manoharan wrote:
> John W. Linville wrote:
> > Mohammed Shafi Shajakhan (1):
> >       ath9k_hw: avoid possible infinite loop in ar9003_get_pll_sqsum_dvc
> 
> Um, this commit doesn't really fix anything - the timeout is also
> arbitrary. Can you remove this from the 3.5 queue ? Thanks.

A review of the patch later, I think it's good. At least there's a
WARN_ON_ONCE() to indicate the situation in which the measurement fails.
It might come in handy as a debugging aid.

Sujith
