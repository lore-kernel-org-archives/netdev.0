From: "Simon Arlott" <simon@fire.lp0.eu>
Subject: Re: strange tcp behavior
Date: Fri, 3 Aug 2007 13:03:46 +0100
Message-ID: <60580.simon.1186142626@5ec7c279.invalid>
References: <20070802095550.GA27226@2ka.mipt.ru>
    <20070802101655.GA14749@2ka.mipt.ru>
    <36758.simon.1186054739@5ec7c279.invalid>
    <46860.212.93.96.73.1186055105.squirrel@mail.screen.lv>
    <48738.simon.1186056932@5ec7c279.invalid>
    <46B21148.2090004@simon.arlott.org.uk>
    <20070802180842.GA6864@2ka.mipt.ru>
    <46B2293B.3020406@simon.arlott.org.uk>
    <20070803082517.GB25582@2ka.mipt.ru>
    <46956.simon.1186140106@5ec7c279.invalid>
    <20070803115624.GD5727@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: john@screen.lv, netdev@vger.kernel.org,
	"David Miller" <davem@davemloft.net>
To: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from proxima.lp0.eu ([85.158.45.36]:41598 "EHLO proxima.lp0.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752269AbXHCMEJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Aug 2007 08:04:09 -0400
In-Reply-To: <20070803115624.GD5727@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, August 3, 2007 12:56, Evgeniy Polyakov wrote:
> On Fri, Aug 03, 2007 at 12:21:46PM +0100, Simon Arlott (simon@fire.lp0.eu) wrote:
>> Since the connection is considered closed, couldn't another socket re-use it?
>>
>> Socket A: Recv data (unread)
>> Socket A: Recv RST
>> Socket B: Reuses connection (same IPs/ports)
>> Socket A: Close
>>
>> Wouldn't that disrupt socket B's use of the connection?
>
> Then it will drop our data, since there were no appropriate handhsake.

Couldn't the sequence numbers be close enough to make the RST valid?

-- 
Simon Arlott
