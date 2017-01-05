From: Shuah Khan <shuah@kernel.org>
Subject: Re: [PATCH v3 net-next 1/2] tools: psock_lib: tighten conditions
 checked in sock_setfilter
Date: Thu, 5 Jan 2017 11:46:32 -0700
Message-ID: <d7735d57-ef28-cdc2-2f05-fa1a764c35f8@kernel.org>
References: <cover.1483555162.git.sowmini.varadhan@oracle.com>
 <3aa068fa482f7cf5381957e9a3ea58550822d1d1.1483555162.git.sowmini.varadhan@oracle.com>
 <d3e75147-475a-823c-3530-5150dd24a63d@kernel.org>
 <20170104225554.GD31756@oracle.com>
 <3be167c0-b7cb-1ab4-6afe-e2e84a3404f5@kernel.org>
 <20170105155407.GH16822@oracle.com>
Reply-To: shuah@kernel.org
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net, willemb@google.com,
        davem@davemloft.net, Shuah Khan <shuah@kernel.org>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from resqmta-po-04v.sys.comcast.net ([96.114.154.163]:50020 "EHLO
        resqmta-po-04v.sys.comcast.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S937597AbdAESrF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2017 13:47:05 -0500
In-Reply-To: <20170105155407.GH16822@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/05/2017 08:54 AM, Sowmini Varadhan wrote:
> On (01/04/17 16:26), Shuah Khan wrote:
>>
>> Could you please split this patch into two. Hardening part in one and
>> the cleanup in a separate patch. This way I can get the hardening fix
>> into 4.10 in my next Kselftest update. Cleanup patch can go in later.
>>
>> thanks,
>> -- Shuah
> 
> I'm a little confused by the comments above.
> 
> Dan's suggestion was that I could have used some other
> tool to generate the code, rather than hand-crafting it as I did.
> In his last message, he suggests that it may be ok to leave
> the hand-crafted version as is (for now), as well.
> 
> To make it clear:
> the current v3 version *is* the "hardening" part. Dan's suggestion is
> that the hand-crafted version can be replaced by bpf_asm generated code
> later. That would be the "cleanup" part, which I was going to do in a
> later commit.
> 
> Does that help?
> 
> --Sowmini
> 

Let's try this again. I want to see a separate patch for the
filter cleanup. I don't want that included in the non-udp packet
check. Please address the readability review comments from me and
Daniel when you send your next version.

thanks,
-- Shuah
