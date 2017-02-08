From: Jarno Rajahalme <jarno@ovn.org>
Subject: Re: [PATCH net-next 7/7] openvswitch: Pack struct sw_flow_key.
Date: Tue, 7 Feb 2017 17:11:52 -0800
Message-ID: <D690A16C-C10E-43F7-822A-43D754D31E92@ovn.org>
References: <1486084206-109903-1-git-send-email-jarno@ovn.org> <1486084206-109903-7-git-send-email-jarno@ovn.org> <CAPWQB7GF8Zy8qskmKu5sNhj2q93pqwK_-Cd20Qm0yZRNvgbZqA@mail.gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Joe Stringer <joe@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:35213 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753568AbdBHBLz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 20:11:55 -0500
Received: by mail-pf0-f196.google.com with SMTP id f144so10364268pfa.2
        for <netdev@vger.kernel.org>; Tue, 07 Feb 2017 17:11:55 -0800 (PST)
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
