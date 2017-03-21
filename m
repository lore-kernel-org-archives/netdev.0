From: Tommi Rantala <tommi.t.rantala@nokia.com>
Subject: Re: "tipc: fix socket timer deadlock" to stable?
Date: Tue, 21 Mar 2017 09:50:20 +0200
Message-ID: <876102a9-a205-36a3-bc29-f0bb2bf70eff@nokia.com>
References: <42aebc97-bd71-a9f8-490b-42d8e81283c6@nokia.com>
 <A2BAEFC30C8FD34388F02C9B3121859D3D7173F1@eusaamb103.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, GUNA <gbalasun@gmail.com>,
        Ying Xue <ying.xue@windriver.com>
To: Jon Maloy <jon.maloy@ericsson.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-he1eur01on0096.outbound.protection.outlook.com ([104.47.0.96]:6272
        "EHLO EUR01-HE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1755783AbdCUHua (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 21 Mar 2017 03:50:30 -0400
In-Reply-To: <A2BAEFC30C8FD34388F02C9B3121859D3D7173F1@eusaamb103.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13.03.2017 14:18, Jon Maloy wrote:
>> -----Original Message-----
>> From: Tommi Rantala [mailto:tommi.t.rantala@nokia.com]
>>
>> We're seeing this tipc deadlock in 4.4.y, that was fixed in the mainline commit
>> f1d048f24e66ba85d3dabf3d076cefa5f2b546b0 "tipc: fix socket timer
>> deadlock".
>>
>> Could/should this patch also be included in the stable kernel trees?
>
> I think it should. If action is required by me here (?) I will repost the commit for 4.4.
>
> ///jon

Hi Jon, yes, please do repost the commit. After reading through 
Documentation/networking/netdev-FAQ.txt, you probably want to send it 
with suitable subject-prefix so that the patch is not lost in the noise.

>> I just checked that the patch applies on top of 4.4.53, only the line numbers
>> are different compared to the upstream commit.

(Actually there is also a small change in the patch context.)

-Tommi
