From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Subject: Re: bandwidth limitation help
Date: Wed, 26 Jul 2006 08:50:11 +1200
Message-ID: <5640c7e00607251350m49fd9cb2n1e3306082d55413b@mail.gmail.com>
References: <3C5BFF28444F434695FB134004DF014701B94425@aplesjustice.dom1.jhuapl.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-f131.google.com ([64.233.182.131]:44579 "EHLO
	nf-out-f131.google.com") by vger.kernel.org with ESMTP
	id S1751585AbWGYUuN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Jul 2006 16:50:13 -0400
Received: by nf-out-f131.google.com with SMTP id k65so133640nfa
        for <netdev@vger.kernel.org>; Tue, 25 Jul 2006 13:50:12 -0700 (PDT)
To: "Piotrowski, Ted P." <Ted.Piotrowski@jhuapl.edu>
In-Reply-To: <3C5BFF28444F434695FB134004DF014701B94425@aplesjustice.dom1.jhuapl.edu>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 7/26/06, Piotrowski, Ted P. <Ted.Piotrowski@jhuapl.edu> wrote:
> Hi,
>
> I am new to the mailing list so I'm not sure if anybody reads these, but
> here goes nothing. I recently read: Linux Advanced Routing & Traffic
> Control HOWTO and have been trying to test my applications using
> bandwidth limitation. All the examples described in the HOWTO do not
> simulate the conditions I need to test my software. What I would like is
> for my bandwidth limitation to empty my UDP buffer at a given rate. I
> have tried using a simple TBF to do this, but all that happens is that
> my application floods the TBF buffer at link speed and the TBF buffer
> quickly overflows and drops packets. I want the packets to actually stay
> in the UDP buffer and be emptied at a given rate without modifying my
> application.
>
> I don't know if any of you are familiar with netem, but it can be used
> in conjuction with tc to add delay to a link. Surprisingly, packets
> delayed by netem appear to remain in the UDP buffer until it is time for
> them to be sent. I would like this same behavior of keeping the packets
> in the UDP buffer, but with bandwidth limitation on the rate at which
> the buffer empties, not just packet delay. Has anybody ever done
> anything like this or can point me to some resources?
>
Have a look at:
http://linux-net.osdl.org/index.php/Netem

I have written my own test scenarios using examples from this website
but I can also send you my small scripts if you want.

Ian
-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
