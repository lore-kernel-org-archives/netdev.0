From: David Miller <davem@davemloft.net>
Subject: Re: [RESEND PATCH 0/9] Namespaceify more of the tcp sysctl knobs
Date: Sun, 07 Feb 2016 14:36:54 -0500 (EST)
Message-ID: <20160207.143654.1285622817453093402.davem@davemloft.net>
References: <1454485617-16541-1-git-send-email-kernel@kyup.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	edumazet@google.com, ebiederm@xmission.com, fan.du@intel.com,
	kaber@trash.net, jmorris@namei.org, alexander.h.duyck@redhat.com,
	kuznet@ms2.inr.ac.ru
To: kernel@kyup.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1454485617-16541-1-git-send-email-kernel@kyup.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nikolay Borisov <kernel@kyup.com>
Date: Wed,  3 Feb 2016 09:46:48 +0200

> This patch series continues making more of the tcp-related
> sysctl knobs be per net-namespace. Most of these apply per
> socket and have global defaults so should be safe and I
> don't expect any breakages. 
> 
> Having those per net-namespace is useful when multiple  
> containers are hosted and it is required to tune the 
> tcp settings for each independently of the host node. 
> 
> I've split the patches to be per-sysctl but after
> the review if the outcome is positive I'm happy
> to either send it in one big blob or just.  

Series applied, thank you.
