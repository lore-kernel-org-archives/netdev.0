From: "Grumbach, Emmanuel" <emmanuel.grumbach@intel.com>
Subject: RE: [PATCH] drivers/net/wireless: Use RCU_INIT_POINTER(x, NULL) in
 iwlwifi/mvm/sta.c
Date: Sun, 30 Mar 2014 07:49:17 +0000
Message-ID: <0BA3FCBA62E2DC44AF3030971E174FB303DBDB42@HASMSX103.ger.corp.intel.com>
References: <1395599756-7861-1-git-send-email-monamagarwal123@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: Monam Agarwal <monamagarwal123@gmail.com>,
	"Berg, Johannes" <johannes.berg@intel.com>,
	"ilw@linux.intel.com" <ilw@linux.intel.com>,
	"linville@tuxdriver.com" <linville@tuxdriver.com>,
	"eliad@wizery.com" <eliad@wizery.com>,
	"Lifshitz, Eytan" <eytan.lifshitz@intel.com>,
	"eyal@wizery.com" <eyal@wizery.com>,
	"Stepanov, Max" <Max.Stepanov@intel.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:2068 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751353AbaC3HtX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Mar 2014 03:49:23 -0400
In-Reply-To: <1395599756-7861-1-git-send-email-monamagarwal123@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> 
> This patch replaces rcu_assign_pointer(x, NULL) with RCU_INIT_POINTER(x,
> NULL)
> 
> The rcu_assign_pointer() ensures that the initialization of a structure
> is carried out before storing a pointer to that structure.
> And in the case of the NULL pointer, there is no structure to initialize.
> So, rcu_assign_pointer(p, NULL) can be safely converted to
> RCU_INIT_POINTER(p, NULL)
> 
> Signed-off-by: Monam Agarwal <monamagarwal123@gmail.com>
> ---
>  drivers/net/wireless/iwlwifi/mvm/sta.c |    8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
> 

Applied - with small change in commit log.
Thank you for your contribution.
