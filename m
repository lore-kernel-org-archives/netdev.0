From: Christian Riesch <christian.riesch-3mrvs1K0uXizZXS1Dc/lvw@public.gmane.org>
Subject: Re: davinci_emac/mdio: SOFT_RESET of EMAC module resets MDIO on AM1808
Date: Mon, 12 Mar 2012 08:04:52 +0100
Message-ID: <CABkLObos_RrKLb338x-JMA4yDg_TEB2S3nr-R6SefRoYCOanBw@mail.gmail.com>
References: <B6A220404B6BFC4BBD2AB91C54D39DF431775E1B@DBDE01.ent.ti.com>
	<1330092923-10899-1-git-send-email-christian.riesch@omicron.at>
	<B6A220404B6BFC4BBD2AB91C54D39DF431776D23@DBDE01.ent.ti.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0181050159=="
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org"
	<davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>,
        "Gole,  Anant"
	<anantgole-l0cyMroinI0@public.gmane.org>
To: "Rajashekhara, Sudhakar" <sudhakar.raj-l0cyMroinI0@public.gmane.org>
Return-path: <davinci-linux-open-source-bounces-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>
In-Reply-To: <B6A220404B6BFC4BBD2AB91C54D39DF431776D23-Er742YJ7I/eIQmiDNMet8wC/G2K4zDHf@public.gmane.org>
List-Unsubscribe: <http://linux.davincidsp.com/mailman/options/davinci-linux-open-source>,
	<mailto:davinci-linux-open-source-request-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org?subject=unsubscribe>
List-Archive: <http://linux.davincidsp.com/pipermail/davinci-linux-open-source>
List-Post: <mailto:davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>
List-Help: <mailto:davinci-linux-open-source-request-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org?subject=help>
List-Subscribe: <http://linux.davincidsp.com/mailman/listinfo/davinci-linux-open-source>,
	<mailto:davinci-linux-open-source-request-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org?subject=subscribe>
Sender: <davinci-linux-open-source-bounces-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>
Errors-To: davinci-linux-open-source-bounces-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org
List-Id: netdev.vger.kernel.org

--===============0181050159==
Content-Type: multipart/alternative; boundary="20cf303f6a26deff0204bb065b1c"

--20cf303f6a26deff0204bb065b1c
Content-Type: text/plain; charset="UTF-8"

On Tuesday, February 28, 2012, Rajashekhara, Sudhakar <sudhakar.raj-l0cyMroinI0@public.gmane.org>
wrote:
> Hi Christian,
>
> On Mon, Feb 27, 2012 at 15:44:54, Rajashekhara, Sudhakar wrote:
>> Hi Christian,
>>
>> On Fri, Feb 24, 2012 at 19:45:23, Christian Riesch wrote:
>> > Hello Sudhakar,
>> >
>> > On Fri, Feb 24, 2012 at 2:02 PM, Rajashekhara, Sudhakar <
sudhakar.raj-l0cyMroinI0@public.gmane.org> wrote:
>> > > On Thu, Feb 23, 2012 at 14:39:49, Christian Riesch wrote:
>> > >> Hi,
>> > >> I observed this behavior on a Texas Instruments AM1808 SoC (AM1808
>> > >> experimenter's kit) running the current mainline kernel:
>> > >>
>>
>> [snip]
>>
>> > >>
>> > >> According to the AM1808 Technical Reference Manual (sections
18.2.14.1
>> > >> and 18.3.3.34 in [1]), writing a 1 to the EMAC_SOFTRESET register
>> > >> resets the EMAC module, but not the MDIO module. However, when I
>> > >> comment out the code above, the MDIO control register is not
affected
>> > >> and the warning 'resetting idled controller' disappears.
>> > >>
>> > >
>> > > But this was not the case for me. Even after commenting out the
above lines,
>> > > I could still see that MDIO was getting reset.
>> >
>> > Uh, I am sorry. I forgot to mention that there is a second
>> > emac_write(EMAC_SOFTRESET,1); in emac_dev_stop() in davinci_emac.c.
>> > This one must also be commented out to make the resetting idled
controller
>> > message go away.
>> >
>> > The patch below shows that changes that I did. May I please ask you to
try
>> > again with these changes?
>> >
>>
>> I was able to reproduce the issue. I'll debug this further and get back
to you.
>>
>
> I was going through the mailing list discussions where a work around for
emac
> soft-reset tie-up to mdio controller has been proposed. I think this was
a known
> issue on TI's da8xx family of devices. Please refer to the thread at
> http://www.spinics.net/lists/netdev/msg140465.html.
>
> Cyril,
> As you have mentioned in your patch, did you get any confirmation from TI
designer
> regarding emac soft reset behavior? I see that nothing has been mentioned
in the
> EMAC user guide.

Ping?

Thanks, Christian

--20cf303f6a26deff0204bb065b1c
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<br><br>On Tuesday, February 28, 2012, Rajashekhara, Sudhakar &lt;<a href=
=3D"mailto:sudhakar.raj-l0cyMroinI0@public.gmane.org">sudhakar.raj-l0cyMroinI0@public.gmane.org</a>&gt; wrote:<br>&gt; =
Hi Christian,<br>&gt;<br>&gt; On Mon, Feb 27, 2012 at 15:44:54, Rajashekhar=
a, Sudhakar wrote:<br>
&gt;&gt; Hi Christian,<br>&gt;&gt;<br>&gt;&gt; On Fri, Feb 24, 2012 at 19:4=
5:23, Christian Riesch wrote:<br>&gt;&gt; &gt; Hello Sudhakar,<br>&gt;&gt; =
&gt;<br>&gt;&gt; &gt; On Fri, Feb 24, 2012 at 2:02 PM, Rajashekhara, Sudhak=
ar &lt;<a href=3D"mailto:sudhakar.raj-l0cyMroinI0@public.gmane.org">sudhakar.raj-l0cyMroinI0@public.gmane.org</a>&gt; w=
rote:<br>
&gt;&gt; &gt; &gt; On Thu, Feb 23, 2012 at 14:39:49, Christian Riesch wrote=
:<br>&gt;&gt; &gt; &gt;&gt; Hi,<br>&gt;&gt; &gt; &gt;&gt; I observed this b=
ehavior on a Texas Instruments AM1808 SoC (AM1808<br>&gt;&gt; &gt; &gt;&gt;=
 experimenter&#39;s kit) running the current mainline kernel:<br>
&gt;&gt; &gt; &gt;&gt;<br>&gt;&gt;<br>&gt;&gt; [snip]<br>&gt;&gt;<br>&gt;&g=
t; &gt; &gt;&gt;<br>&gt;&gt; &gt; &gt;&gt; According to the AM1808 Technica=
l Reference Manual (sections 18.2.14.1<br>&gt;&gt; &gt; &gt;&gt; and 18.3.3=
.34 in [1]), writing a 1 to the EMAC_SOFTRESET register<br>
&gt;&gt; &gt; &gt;&gt; resets the EMAC module, but not the MDIO module. How=
ever, when I<br>&gt;&gt; &gt; &gt;&gt; comment out the code above, the MDIO=
 control register is not affected<br>&gt;&gt; &gt; &gt;&gt; and the warning=
 &#39;resetting idled controller&#39; disappears.<br>
&gt;&gt; &gt; &gt;&gt;<br>&gt;&gt; &gt; &gt;<br>&gt;&gt; &gt; &gt; But this=
 was not the case for me. Even after commenting out the above lines,<br>&gt=
;&gt; &gt; &gt; I could still see that MDIO was getting reset.<br>&gt;&gt; =
&gt;<br>
&gt;&gt; &gt; Uh, I am sorry. I forgot to mention that there is a second<br=
>&gt;&gt; &gt; emac_write(EMAC_SOFTRESET,1); in emac_dev_stop() in davinci_=
emac.c.<br>&gt;&gt; &gt; This one must also be commented out to make the re=
setting idled controller<br>
&gt;&gt; &gt; message go away.<br>&gt;&gt; &gt;<br>&gt;&gt; &gt; The patch =
below shows that changes that I did. May I please ask you to try<br>&gt;&gt=
; &gt; again with these changes?<br>&gt;&gt; &gt;<br>&gt;&gt;<br>&gt;&gt; I=
 was able to reproduce the issue. I&#39;ll debug this further and get back =
to you.<br>
&gt;&gt;<br>&gt;<br>&gt; I was going through the mailing list discussions w=
here a work around for emac<br>&gt; soft-reset tie-up to mdio controller ha=
s been proposed. I think this was a known<br>&gt; issue on TI&#39;s da8xx f=
amily of devices. Please refer to the thread at<br>
&gt; <a href=3D"http://www.spinics.net/lists/netdev/msg140465.html">http://=
www.spinics.net/lists/netdev/msg140465.html</a>.<br>&gt;<br>&gt; Cyril,<br>=
&gt; As you have mentioned in your patch, did you get any confirmation from=
 TI designer<br>
&gt; regarding emac soft reset behavior? I see that nothing has been mentio=
ned in the<br>&gt; EMAC user guide.<br><br>Ping?<br><br>Thanks, Christian

--20cf303f6a26deff0204bb065b1c--

--===============0181050159==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--===============0181050159==--
