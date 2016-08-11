From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 2/3] net: mpls fixes for GSO
Date: Thu, 11 Aug 2016 07:47:02 -0600
Message-ID: <00b1791d-d90e-7f78-fa06-cdb67987816f@cumulusnetworks.com>
References: <1470897812-8213-1-git-send-email-roopa@cumulusnetworks.com>
 <1470897812-8213-3-git-send-email-roopa@cumulusnetworks.com>
 <20160811074735.GA32385@penelope.isobedori.kobe.vergenet.net>
 <20160811133043.GA10308@penelope.isobedori.kobe.vergenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	buytenh@wantstofly.org, ebiederm@xmission.com,
	rshearma@brocade.com, tom@herbertland.com, tgraf@suug.ch,
	olivier.dugeon@orange.com
To: Simon Horman <simon.horman@netronome.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f170.google.com ([209.85.223.170]:35671 "EHLO
	mail-io0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932162AbcHKNrP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Aug 2016 09:47:15 -0400
Received: by mail-io0-f170.google.com with SMTP id m101so6378432ioi.2
        for <netdev@vger.kernel.org>; Thu, 11 Aug 2016 06:47:15 -0700 (PDT)
In-Reply-To: <20160811133043.GA10308@penelope.isobedori.kobe.vergenet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Simon:

On 8/11/16 7:30 AM, Simon Horman wrote:
> On Thu, Aug 11, 2016 at 09:47:36AM +0200, Simon Horman wrote:
>> > On Wed, Aug 10, 2016 at 11:43:31PM -0700, Roopa Prabhu wrote:
>>> > > From: David Ahern <dsa@cumulusnetworks.com>
>>> > > 
>>> > > Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
>>> > > Reported-by: Lennert Buytenhek <buytenh@wantstofly.org>
>> > 
>> > Thanks. This looks like it should be correct to me.  However, I would
>> > appreciate it if you could give me a little time to test it against OvS.
> Unfortunately I was a little bit optimistic.
> 
> I tested this patch on top of net-next.
> My setup is OVS receiving TCP/IP from an ethernet interface,
> adding an MPLS LSE; and outputting to a GRE vport (netdev).

Miscommunication between Roopa and myself. I was not ready for the patches to hit netdev yet. As you found more testing is needed.

Since you hit a panic can you share the commands used to configure the node?

David
