From: Jarno Rajahalme <jarno@ovn.org>
Subject: Re: [PATCH net-next 7/7] openvswitch: Pack struct sw_flow_key.
Date: Tue, 7 Feb 2017 21:31:33 -0800
Message-ID: <AE943ACB-5F01-4B1A-8F59-4135D7942B85@ovn.org>
References: <1486084206-109903-1-git-send-email-jarno@ovn.org> <1486084206-109903-7-git-send-email-jarno@ovn.org> <CAPWQB7GF8Zy8qskmKu5sNhj2q93pqwK_-Cd20Qm0yZRNvgbZqA@mail.gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Joe Stringer <joe@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:33251 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932177AbdBHFbg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 00:31:36 -0500
Received: by mail-pg0-f68.google.com with SMTP id 194so14123177pgd.0
        for <netdev@vger.kernel.org>; Tue, 07 Feb 2017 21:31:36 -0800 (PST)
In-Reply-To: <CAPWQB7GF8Zy8qskmKu5sNhj2q93pqwK_-Cd20Qm0yZRNvgbZqA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Feb 6, 2017, at 11:15 PM, Joe Stringer <joe@ovn.org> wrote:
> 
> On 2 February 2017 at 17:10, Jarno Rajahalme <jarno@ovn.org> wrote:
>> struct sw_flow_key has two 16-bit holes. Move the most matched
>> conntrack match fields there.  In some typical cases this reduces the
>> size of the key that needs to be hashed into half and into one cache
>> line.
>> 
>> Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
> 
> Looks like this misses the zeroing in ovs_nla_get_flow_metadata();
> might want to double-check for any other memset/copies of the key->ct
> field.

Good catch. Looked, there are no other places to change.

Will rebase to current net-next and repost.

 Jarno
