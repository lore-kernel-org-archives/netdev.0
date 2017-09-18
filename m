From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 09/11] bnxt_en: bnxt: add TC flower filter
 offload support
Date: Mon, 18 Sep 2017 11:52:05 +0200
Message-ID: <20170918095205.GB1951@nanopsycho.orion>
References: <1503942035-24924-1-git-send-email-michael.chan@broadcom.com>
 <1503942035-24924-10-git-send-email-michael.chan@broadcom.com>
 <20170911133607.GD1869@nanopsycho>
 <CAKvpyk1iV4z_f7cUA8DL1nU772hPtiZC4MtjA9t=S5J=8EcD-A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Chan <michael.chan@broadcom.com>,
        David Miller <davem@davemloft.net>,
        Netdev <netdev@vger.kernel.org>
To: Sathya Perla <sathya.perla@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:37571 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753882AbdIRJwH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 05:52:07 -0400
Received: by mail-wr0-f193.google.com with SMTP id u48so4753243wrf.4
        for <netdev@vger.kernel.org>; Mon, 18 Sep 2017 02:52:06 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAKvpyk1iV4z_f7cUA8DL1nU772hPtiZC4MtjA9t=S5J=8EcD-A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Sep 18, 2017 at 11:43:22AM CEST, sathya.perla@broadcom.com wrote:
>On Mon, Sep 11, 2017 at 7:06 PM, Jiri Pirko <jiri@resnulli.us> wrote:
>> Mon, Aug 28, 2017 at 07:40:33PM CEST, michael.chan@broadcom.com wrote:
>>>From: Sathya Perla <sathya.perla@broadcom.com>
>>>
>>>This patch adds support for offloading TC based flow
>>>rules and actions for the 'flower' classifier in the bnxt_en driver.
>>>It includes logic to parse flow rules and actions received from the
>>>TC subsystem, store them and issue the corresponding
>>>hwrm_cfa_flow_alloc/free FW cmds. L2/IPv4/IPv6 flows and drop,
>>>redir, vlan push/pop actions are supported in this patch.
>>>
>>>In this patch the hwrm_cfa_flow_xxx routines are just stubs.
>>>The code for these routines is introduced in the next patch for easier
>>>review. Also, the code to query the TC/flower action stats will
>>>be introduced in a subsequent patch.
>>
>> Hi.
>>
>> You are missing checks for the offload. Please see nfp as an example:
>> Function nfp_flower_setup_tc:
>>
>>             !is_classid_clsact_ingress(cls_flower->common.classid) ||
>>             cls_flower->common.chain_index)
>
>Thanks for catching this...will send a patch.
>
>>
>> Do you support both ingress and egress or ingress only?
>
>Ingress only for flower offload.

Cool, the check would resolve it. Thanks!
