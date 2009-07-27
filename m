From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/bridge: use kobject_put to release kobject in
 br_add_if error path
Date: Sun, 26 Jul 2009 19:21:09 -0700 (PDT)
Message-ID: <20090726.192109.14263864.davem@davemloft.net>
References: <1248426392-30777-1-git-send-email-dfeng@redhat.com>
	<20090724083607.6b91282d@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dfeng@redhat.com, bridge@lists.linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755752AbZG0CVF@vger.kernel.org>
In-Reply-To: <20090724083607.6b91282d@nehalam>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Fri, 24 Jul 2009 08:36:07 -0700

> On Fri, 24 Jul 2009 17:06:32 +0800
> Xiaotian Feng <dfeng@redhat.com> wrote:
> 
>> kobject_init_and_add will alloc memory for kobj->name, so in br_add_if
>> error path, simply use kobject_del will not free memory for kobj->name.
>> Fix by using kobject_put instead, kobject_put will internally calls
>> kobject_del and frees memory for kobj->name.
>> 
>> Signed-off-by: Xiaotian Feng <dfeng@redhat.com>
...
> 
> I assume you tested this by doing something like adding two interfaces
> with the same MAC address to a bridge.
> 
> Acked-by: Stephen Hemminger <shemminger@vyatta.com>

Applied, thanks!
