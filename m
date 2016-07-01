From: Jason Baron <jbaron@akamai.com>
Subject: Re: strange Mac OSX RST behavior
Date: Fri, 1 Jul 2016 14:26:49 -0400
Message-ID: <5776B5E9.4080100@akamai.com>
References: <1467385815-6357-1-git-send-email-jbaron@akamai.com>
 <5776A3A4.8000503@hpe.com> <5776A607.70800@akamai.com>
 <20160701191609.1fc1c045@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: Rick Jones <rick.jones2@hpe.com>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>, <davem@davemloft.net>,
	<eric.dumazet@gmail.com>
To: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160701191609.1fc1c045@lxorguk.ukuu.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 07/01/2016 02:16 PM, One Thousand Gnomes wrote:
>> yes, we do in fact see a POLLRDHUP from the FIN in this case and
>> read of zero, but we still have more data to write to the socket, and
>> b/c the RST is dropped here, the socket stays in TIME_WAIT until
>> things eventually time out...
> 
> After the FIN when you send/retransmit your next segment do you then get
> a valid RST back from the Mac end?
> 
> Alan
> 

No, we only get the single RST after the FIN from the Mac side which
is dropped. I would have expected the RST from the Mac after the
retransmits, but we don't see any further transmits from the Mac.
And the linux socket stays in CLOSE-WAIT (i mistakingly said
TIME_WAIT above).

For reference, I put the packet exchange in my initial mail.

Thanks,

-Jason
