From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 1/1 v2] net: rmnet_data: Initial implementation
Date: Tue, 14 Mar 2017 07:55:30 +0100
Message-ID: <20170314065530.GA1863@nanopsycho.orion>
References: <1489390989-2408-1-git-send-email-subashab@codeaurora.org>
 <1489390989-2408-2-git-send-email-subashab@codeaurora.org>
 <20170313085420.GA1796@nanopsycho>
 <868aee1b58aa4365708966956decf6d3@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, fengguang.wu@intel.com
To: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:36525 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750778AbdCNGzd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Mar 2017 02:55:33 -0400
Received: by mail-wm0-f67.google.com with SMTP id v190so13213205wme.3
        for <netdev@vger.kernel.org>; Mon, 13 Mar 2017 23:55:32 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <868aee1b58aa4365708966956decf6d3@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Mar 13, 2017 at 11:01:15PM CET, subashab@codeaurora.org wrote:
>On 2017-03-13 02:54, Jiri Pirko wrote:
>> Mon, Mar 13, 2017 at 08:43:09AM CET, subashab@codeaurora.org wrote:
>> > RmNet Data driver provides a transport agnostic MAP (multiplexing and
>> 
>> Why "data"? Why not just "rmnet"??
>> 
>> Btw, what is "RmNet". Google does not give me much. Is it some
>> priprietady Qualcomm thing? Is there some standard behind it?
>> 
>
>Hi Jiri
>
>Rm interface is used to describe an application processor tethered to
>Qualcomm Technologies, Inc. modems. Since these are netdevices,

I believe that this code should be a part of that driver, not a generic
code in net/


>the term RmNet is used. I don't think there are published standards
>available for this but I can provide relevant information and
>document it as well.
>
>rmnet was used for a USB based physical transport earlier, hence
>this platform agnostic multiplexing driver was named as rmnet_data.

ok, so?
