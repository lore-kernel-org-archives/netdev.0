From: Lawrence Brakmo <brakmo@fb.com>
Subject: Re: [RFC PATCH v5 net-next 4/4] tcp: add NV congestion control
Date: Wed, 26 Aug 2015 00:05:43 +0000
Message-ID: <D20249D6.71D2%brakmo@fb.com>
References: <1438738748-1756255-1-git-send-email-brakmo@fb.com>
 <1438738748-1756255-5-git-send-email-brakmo@fb.com>
 <CA++eYdvYopM+TSiWa+gt4Z0RkjAM2Kyxvga8XodSm4w=kSmxVw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>, Kernel Team <Kernel-team@fb.com>,
	"Neal Cardwell" <ncardwell@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Yuchung Cheng <ycheng@google.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:12735 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932899AbbHZAF4 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Aug 2015 20:05:56 -0400
In-Reply-To: <CA++eYdvYopM+TSiWa+gt4Z0RkjAM2Kyxvga8XodSm4w=kSmxVw@mail.gmail.com>
Content-Language: en-US
Content-ID: <FCEB2622965E384A9119945C849F948D@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 8/5/15, 5:51 PM, "knneth@gmail.com on behalf of Kenneth Klette
Jonassen" <knneth@gmail.com on behalf of kennetkl@ifi.uio.no> wrote:

>On Wed, Aug 5, 2015 at 3:39 AM, Lawrence Brakmo <brakmo@fb.com> wrote:
>> This is a request for comments.
>
>Nice to see more development on delay-based congestion control.
>
>It would be good to see how NV stacks up against CDG. Any chance of
>adding cdg as a congestion control parameter to your experiments?

Done. I=B9m updating the TCP-NV page with the updated results, should b=
e
done by tomorrow (8/26).

>Experiments on NV without its temporary cwnd reductions would also be
>of interest -- to get a reference of how effective this mechanism is.

Done. It turns out that it only improves fairness a little but hurts
P99 latencies more significantly. So it is now off by default.
Thanks for making me re-examine this feature.
=20
