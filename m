From: "Mala Anand" <manand@us.ibm.com>
Subject: Early SPECWeb99 results on 2.5.33 with TSO on e1000
Date: Tue, 10 Sep 2002 09:59:27 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF085D17C8.33546271-ON87256C30.005200C4@boulder.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Return-path: <netdev-bounce@oss.sgi.com>
To: inux-net@vger.kernel.org, linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I am resending this note with the subject heading, so that
it can be viewed through the subject catagory.

=A0>=A0"David S. Miller" wrote:
>> NAPI is also not the panacea to all problems in the world.

=A0=A0=A0>Mala did some testing on this a couple of weeks back. It appear=
s that
=A0=A0=A0>NAPI damaged performance significantly.



>http://www-124.ibm.com/developerworks/opensource/linuxperf/netperf/resul=
ts/july_02/netperf2.5.25results.htm



>Unfortunately it is not listed what e1000 and core NAPI
>patch was used. Also, not listed, are the RX/TX mitigation
>and ring sizes given to the kernel module upon loading.
The default driver that is included in 2.5.25 kernel for Intel
gigabit adapter was used for the baseline test and the NAPI driver
was downloaded from Robert Olsson's website. I have updated my web
page to include Robert's patch. However it is given there for reference
purpose only. Except for the ones mentioned explicitly the rest of
the configurable values used are default. The default for RX/TX mitigatio=
n
is 64 microseconds and the default ring size is 80.

I have added statistics collected during the test to my web site. I do
want to analyze and understand how NAPI can be improved in my tcp_stream
test. Last year around November, when I first tested NAPI, I did find NAP=
I
results better than the baseline using udp_stream. However I am
concentrating on tcp_stream since that is where NAPI can be improved in
my setup. I will update the website as I do more work on this.


>Robert can comment on optimal settings
I saw Robert's postings. Looks like he may have a more recent version of
NAPI
driver than the one I used. I also see 2.5.33 has NAPI, I will move to
2.5.33
and continue my work on that.


>Robert and Jamal can make a more detailed analysis of Mala's
>graphs than I.
Jamal has questioned about socket buffer size that I used, I have tried
132k
socket buffer size in the past and I didn't see much difference in my
tests.
I will add that to my list again.


Regards,
    Mala


   Mala Anand
   IBM Linux Technology Center - Kernel Performance
   E-mail:manand@us.ibm.com
   http://www-124.ibm.com/developerworks/opensource/linuxperf
   http://www-124.ibm.com/developerworks/projects/linuxperf
   Phone:838-8088; Tie-line:678-8088
