From: Cyprien LAPLACE <cyprien.laplace@trango-systems.com>
Subject: Re: Is the TCP-code threaded?
Date: Sat, 24 Feb 2007 12:40:53 +0100
Message-ID: <45E02445.8020202@trango-systems.com>
References: <45DF7B13.6040407@ifi.uio.no> <e92e3a770702240129w14dc8f2oa4b3e99f423f4704@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net@vger.kernel.org
To: kalash nainwal <nirvana.code@gmail.com>
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <e92e3a770702240129w14dc8f2oa4b3e99f423f4704@mail.gmail.com>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

kalash nainwal wrote:
> On 2/24/07, Kristian Evensen <kristrev@ifi.uio.no> wrote:
>> Hello,
>>
>> I have been looking quite deeply into the TCP-code, but there is one
>> thing I simply dont manage to understand. Can the code process more than
>> one skb on a socket at the time, or is it strictly one and one?
>>
>> E.g say that you are going to send something (an skb), and you recieve
>> an ack at the same time. Will the kernel finish whatever of the two
>> comes first (say, finish sending) or can it, in the middle of treating
>> the new packet to send, do a switch and process the ack?
>>
> send happes in process context, recv in interrupt context...isn't it?
Hum, except if sending is delayed because of lack of windows, waiting
for ack etc. In this case, sending may be delayed to soft-irq and
single-threaded with reception (data are processed in soft-irq)..

Is this correct ?

Cyprien
