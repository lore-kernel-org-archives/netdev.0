From: Rick Jones <rick.jones2@hp.com>
Subject: Re: TCP partial write
Date: Mon, 15 Jun 2009 10:59:55 -0700
Message-ID: <4A368C1B.7030509@hp.com>
References: <394b5e260906141252g56d4275k185230f724b842ac@mail.gmail.com>	<4A368049.7080903@hp.com> <20090615102655.5059302d@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Paul Martin <srucnoc@gmail.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0029.austin.hp.com ([15.216.28.36]:34165 "EHLO
	g1t0029.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757543AbZFOR7y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jun 2009 13:59:54 -0400
In-Reply-To: <20090615102655.5059302d@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> On Mon, 15 Jun 2009 10:09:29 -0700
> Rick Jones <rick.jones2@hp.com> wrote:

>> And you should/must assume that at the other end, your recv/read calls will
>> return with between 0 and however many bytes you ask of them, with 0 meaning
>> the remote has said it has nothing left to give.
>>
> 
> 
> Actually on a blocking socket 0 means other end has closed.

Overly poetic wording on my part, using "said it has nothing left to give" to 
mean "other end has closed" :)

rick jones
