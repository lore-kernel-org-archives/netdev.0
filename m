From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Subject: Re: [PATCH net-next 1/1 v2] net: rmnet_data: Initial implementation
Date: Mon, 13 Mar 2017 16:01:15 -0600
Message-ID: <868aee1b58aa4365708966956decf6d3@codeaurora.org>
References: <1489390989-2408-1-git-send-email-subashab@codeaurora.org>
 <1489390989-2408-2-git-send-email-subashab@codeaurora.org>
 <20170313085420.GA1796@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, fengguang.wu@intel.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:45466 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751874AbdCMWBT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 18:01:19 -0400
In-Reply-To: <20170313085420.GA1796@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2017-03-13 02:54, Jiri Pirko wrote:
> Mon, Mar 13, 2017 at 08:43:09AM CET, subashab@codeaurora.org wrote:
>> RmNet Data driver provides a transport agnostic MAP (multiplexing and
> 
> Why "data"? Why not just "rmnet"??
> 
> Btw, what is "RmNet". Google does not give me much. Is it some
> priprietady Qualcomm thing? Is there some standard behind it?
> 

Hi Jiri

Rm interface is used to describe an application processor tethered to
Qualcomm Technologies, Inc. modems. Since these are netdevices,
the term RmNet is used. I don't think there are published standards
available for this but I can provide relevant information and
document it as well.

rmnet was used for a USB based physical transport earlier, hence
this platform agnostic multiplexing driver was named as rmnet_data.
