From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH][E1000E] some cleanups
Date: Tue, 02 Oct 2007 10:06:16 -0700
Message-ID: <47027A88.1000206@intel.com>
References: <1191174077.6165.11.camel@localhost>	 <46FFE809.8020504@intel.com> <1191178881.6165.40.camel@localhost>	 <46FFF7AD.7090309@garzik.org> <1191180669.6165.50.camel@localhost>	 <4700549A.70409@intel.com> <1191327916.4353.10.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:63845 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751671AbXJBRGq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Oct 2007 13:06:46 -0400
In-Reply-To: <1191327916.4353.10.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Sun, 2007-30-09 at 18:59 -0700, Kok, Auke wrote:
> 
>> the IDs are the only thing needed to enable all pci-e e1000 hardware.
> 
> I'll give it a whirl in the next few days. It failed as a module (with
> e1000 compiled out), i will try to compile it in. I have access to the
> hardware in quiet times - so it may be the weekend.
> 
>> by all means we need to have guys like you and Jeff test the commented IDs! I've
>> been doing this myself and the e1000e driver goes to our labs for a period of
>> testing from next week. Unfortunately they don't know how to break it that good as
>> some of you guys ;)
>>
>> I'll personally try to get an 82571EB tested on monday.
> 
> How did that go?

Emil just ran overnight testing on a 82571, a 81572, a ich9 and an esb2 onboard
LOM. All passed traffic OK. There was one issue/unconfirmed bug with jumbo frames
that I'm currently looking at, but nothing at normal MTU's.

So, you should be just fine using 82571's with e1000e for now.

Auke
