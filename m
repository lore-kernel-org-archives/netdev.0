From: Nicholas Mc Guire <der.herr@hofr.at>
Subject: Re: [PATCH 2/2] ath10k: core: harmonize error case handling in
	ath10k_core_start
Date: Sun, 15 Mar 2015 11:17:58 +0100
Message-ID: <20150315101758.GA28477@opentech.at>
References: <1426323313-1344-1-git-send-email-hofrat@osadl.org> <550497A0.5040508@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nicholas Mc Guire <hofrat@osadl.org>,
	Kalle Valo <kvalo@qca.qualcomm.com>,
	Michal Kazior <michal.kazior@tieto.com>,
	ath10k@lists.infradead.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <550497A0.5040508@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 14 Mar 2015, Sergei Shtylyov wrote:

> Hello.
>
> On 03/14/2015 11:55 AM, Nicholas Mc Guire wrote:
>
>> All of the bringup/init functions called in ath10k_core_start return 0 on
>> success and != 0 on failure - ath10k_wmi_wait_for_service_ready and
>> ath10k_wmi_wait_for_unified_ready were adjusted to fit this model and the
>> call sites here fixed up accordingly.
>
>    If you've changed the sense of these function's results, you need to  
> adjust the call sites in the same patch, because otherwise one wouldn't 
> be able to bisect this...
>

yup both patches would mess up if individually applied or reverted.
sorry my ignorance - did not think of that problem - will fix it 
up as a single patch and repost. 

thx!
hofrat
