From: Chris Friesen <cfriesen@nortelnetworks.com>
Subject: Re: PATCH Re: udp weirdness
Date: Tue, 01 Oct 2002 10:52:55 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3D99B6C7.3010302@nortelnetworks.com>
References: <200210011440.SAA19721@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.CA, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

kuznet@ms2.inr.ac.ru wrote:

> Feel free to implement. :-)

I may have to poke around...if nothing else I'll learn more about the 
networking code...

> What? If your applications is enough clever to handle ENOBUFS right,
> set IP_RECVERR and live in peace.

The original poster was complaining about messages being silently 
dropped when there is congestion.  If IP_RECVERR is turned on, would 
sendto() then return -1 so I know to try and read the error messages? 
I'm assuming I get ENOBUFS back in the ee_code field?  Or can I get away 
with reading errno and ignoring the error queue?

I've never used IP_RECVERR and there doesn't seem to be a lot of 
documentation about it.

Chris
