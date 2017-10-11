From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCHv4 iproute2 2/2] lib/libnetlink: update rtnl_talk to
 support malloc buff at run time
Date: Wed, 11 Oct 2017 08:35:35 -0600
Message-ID: <7501028d-4433-3a08-3a11-4a8b7c0e1404@gmail.com>
References: <1506605626-1744-1-git-send-email-haliu@redhat.com>
 <1506605626-1744-3-git-send-email-haliu@redhat.com>
 <20171002103708.0572704b@xeon-e3> <20171009202525.GR32278@orbyte.nwl.cc>
 <20171010064117.ipyarf5ml7fwnzdv@unicorn.suse.cz>
 <20171010094743.6ae2baa8@shemminger-XPS-13-9360>
 <20171011111007.GA11332@orbyte.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Phil Sutter <phil@nwl.cc>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Michal Kubecek <mkubecek@suse.cz>,
        Hangbin Liu <haliu@redhat.com>, netdev@vger.kernel.org,
        Hangbin Liu <liuhangbin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:52856 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751744AbdJKOfc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 10:35:32 -0400
Received: by mail-pf0-f182.google.com with SMTP id e64so1193239pfk.9
        for <netdev@vger.kernel.org>; Wed, 11 Oct 2017 07:35:32 -0700 (PDT)
In-Reply-To: <20171011111007.GA11332@orbyte.nwl.cc>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/11/17 5:10 AM, Phil Sutter wrote:
> less than 10% overall. Given the short time a single call to 'ip'
> typically takes, I don't think the difference is noticeable even in
> highly performance critical applications.

high performance critical applications should not be forking ip and
definitely not for 1 command at a time.
