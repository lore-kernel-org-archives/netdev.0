From: Park Lee <parklee_sel@yahoo.com>
Subject: Re: Must every packet have a creating socket? (was Re: Does a forwarded packet has a local socket with it?)
Date: Thu, 21 Apr 2005 06:05:37 -0700 (PDT)
Message-ID: <20050421130537.96620.qmail@web51501.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Horman <nhorman@redhat.com>,
	Masoud Sharbiani <masouds@masoud.ir>, jamal <hadi@cyberus.ca>,
	linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: Rick Jones <rick.jones2@hp.com>
In-Reply-To: 6667
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 20 Apr 2005 at 18:20, Rick Jones wrote:
>> On Wed, 20 Apr 2005 at 10:29, Park Lee wrote:
>> Can I think that every packet (e.g. IP packet) must
>> have a corresponding creating socket? (i.e. Must 
>> every packet be created by a socket?) 
>
> No.  ICMP messages come to mind - although I 
> _suppose_ that since those are in response to other 
> traffic, you could claim it was in response to 
> something sent from a "socket" or "endpoint" - 
> depends on how far away you consider it to still 
> be  from a socket.

    But as I know, The Linux network component creates
two special purpose sockets for use by the AF_INET
protocol family. The tcp socket is used to send resets
when a TCP packet is rejected, since there may be no
local socket corresponding to the packet. The icmp
socket is used to send ICMP messages.
    Then, ICMP echo replies are asociated with the
special kernel socket.
    So, I still think that every packet (e.g. IP
packet) must have a corresponding creating socket. 
    Am I right?

    Thank you.

Best Regards,
Park Lee


		
__________________________________ 
Do you Yahoo!? 
Yahoo! Small Business - Try our new resources site!
http://smallbusiness.yahoo.com/resources/ 
