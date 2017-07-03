From: Waiman Long <longman@redhat.com>
Subject: Re: [PATCH net 1/2] vxlan: fix hlist corruption
Date: Mon, 3 Jul 2017 09:25:45 -0400
Message-ID: <bdd5d0e8-b8fa-2c81-07ad-17ad89b6c052@redhat.com>
References: <cover.1499014738.git.jbenc@redhat.com>
 <61fd10b88f9eeab8f95a3a73f7e27358fcdcd781.1499014738.git.jbenc@redhat.com>
 <38e4eb5a-2d9e-4f38-f043-42a1dd449bfb@redhat.com>
 <20170703102359.246d68a2@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
        "John W. Linville" <linville@tuxdriver.com>,
        pravin shelar <pshelar@ovn.org>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3592 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754284AbdGCNZr (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 3 Jul 2017 09:25:47 -0400
In-Reply-To: <20170703102359.246d68a2@griffin>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/03/2017 04:23 AM, Jiri Benc wrote:
> On Sun, 2 Jul 2017 16:06:10 -0400, Waiman Long wrote:
>> I didn't see any init code for hlist4 and hlist6. Is vxlan_dev going to
>> be *zalloc'ed so that they are guaranteed to be NULL? If not, you may
>> need to add  init code as not both hlists will be hashed and so one of
>> them may contain invalid data.
> Yes, it's zalloced via alloc_netdev. No need to init the fields
> explicitly.
>
>  Jiri

Thanks for the clarification.

-Longman
