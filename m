From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [Query] Delayed vxlan socket creation?
Date: Wed, 14 Dec 2016 10:29:31 +0100
Message-ID: <20161214102931.307efe94@griffin>
References: <5A90DA2E42F8AE43BC4A093BF06788481A9457F1@SHSMSX103.ccr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "mrjana@gmail.com" <mrjana@gmail.com>
To: "Du, Fan" <fan.du@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56592 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754932AbcLNJ3f (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 14 Dec 2016 04:29:35 -0500
In-Reply-To: <5A90DA2E42F8AE43BC4A093BF06788481A9457F1@SHSMSX103.ccr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 14 Dec 2016 07:49:24 +0000, Du, Fan wrote:
> I'm interested to one Docker issue[1] which looks like related to kernel vxlan socket creation
> as described in the thread. From my limited knowledge here, socket creation is synchronous ,
> and after the *socket* syscall, the sock handle will be valid and ready to linkup.
> 
> Somehow I'm not sure the detailed scenario here, and which/how possible commit fix?

baf606d9c9b1^..56ef9c909b40

 Jiri
