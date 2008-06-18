From: "John Rigby" <jcrigby@gmail.com>
Subject: Re: [PATCH 1/2] fs_enet: fix checkpatch.pl problems
Date: Tue, 17 Jun 2008 22:12:35 -0600
Message-ID: <4b73d43f0806172112s63ada35brb2e27f3262d7c07@mail.gmail.com>
References: <1213743794-3537-1-git-send-email-jrigby@freescale.com>
	<1213743794-3537-2-git-send-email-jrigby@freescale.com>
	<485886D9.5070800@garzik.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1146093477=="
Cc: Scott Wood <scottwood@freescale.com>, linuxppc-dev@ozlabs.org,
	Sam Ravnborg <sam@ravnborg.org>, netdev@vger.kernel.org
To: "Jeff Garzik" <jeff@garzik.org>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <485886D9.5070800@garzik.org>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Mime-version: 1.0
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

--===============1146093477==
Content-Type: multipart/alternative;
	boundary="----=_Part_18767_19192528.1213762355533"

------=_Part_18767_19192528.1213762355533
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Sorry, I thought I was doing the right thing to base the patch on Kumar's
patch that removes the CONFIG_PPC_CPM_NEW_BINDING stuff.  That is likely why
it did not apply.

On Tue, Jun 17, 2008 at 9:54 PM, Jeff Garzik <jeff@garzik.org> wrote:

> John Rigby wrote:
>
>> Fixed all errors and warnings that checkpatch.pl
>> reports if this was a new submission.
>> Also changed instances of fec_t to struct fec in
>> mac-fec.c and mii-fec.c.
>>
>> This is in preparation of adding MPC5121 support.
>>
>> Signed-off-by: John Rigby <jrigby@freescale.com>
>> ---
>>  drivers/net/fs_enet/fs_enet-main.c |   70
>> ++++++++++++++++++++---------------
>>  drivers/net/fs_enet/fs_enet.h      |   15 +++++---
>>  drivers/net/fs_enet/mac-fcc.c      |    7 ++--
>>  drivers/net/fs_enet/mac-fec.c      |   40 ++++++++++----------
>>  drivers/net/fs_enet/mac-scc.c      |   13 ++++---
>>  drivers/net/fs_enet/mii-bitbang.c  |    4 +-
>>  drivers/net/fs_enet/mii-fec.c      |   23 +++++++-----
>>  7 files changed, 95 insertions(+), 77 deletions(-)
>>
>
> patch does not apply
>
>
>
> _______________________________________________
> Linuxppc-dev mailing list
> Linuxppc-dev@ozlabs.org
> https://ozlabs.org/mailman/listinfo/linuxppc-dev
>

------=_Part_18767_19192528.1213762355533
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Sorry, I thought I was doing the right thing to base the patch on Kumar&#39;s patch that removes the CONFIG_PPC_CPM_NEW_BINDING stuff.&nbsp; That is likely why it did not apply.<br><br><div class="gmail_quote">On Tue, Jun 17, 2008 at 9:54 PM, Jeff Garzik &lt;<a href="mailto:jeff@garzik.org">jeff@garzik.org</a>&gt; wrote:<br>
<blockquote class="gmail_quote" style="border-left: 1px solid rgb(204, 204, 204); margin: 0pt 0pt 0pt 0.8ex; padding-left: 1ex;"><div class="Ih2E3d">John Rigby wrote:<br>
<blockquote class="gmail_quote" style="border-left: 1px solid rgb(204, 204, 204); margin: 0pt 0pt 0pt 0.8ex; padding-left: 1ex;">
Fixed all errors and warnings that checkpatch.pl<br>
reports if this was a new submission.<br>
Also changed instances of fec_t to struct fec in<br>
mac-fec.c and mii-fec.c.<br>
<br>
This is in preparation of adding MPC5121 support.<br>
<br>
Signed-off-by: John Rigby &lt;<a href="mailto:jrigby@freescale.com" target="_blank">jrigby@freescale.com</a>&gt;<br>
---<br>
&nbsp;drivers/net/fs_enet/fs_enet-main.c | &nbsp; 70 ++++++++++++++++++++---------------<br>
&nbsp;drivers/net/fs_enet/fs_enet.h &nbsp; &nbsp; &nbsp;| &nbsp; 15 +++++---<br>
&nbsp;drivers/net/fs_enet/mac-fcc.c &nbsp; &nbsp; &nbsp;| &nbsp; &nbsp;7 ++--<br>
&nbsp;drivers/net/fs_enet/mac-fec.c &nbsp; &nbsp; &nbsp;| &nbsp; 40 ++++++++++----------<br>
&nbsp;drivers/net/fs_enet/mac-scc.c &nbsp; &nbsp; &nbsp;| &nbsp; 13 ++++---<br>
&nbsp;drivers/net/fs_enet/mii-bitbang.c &nbsp;| &nbsp; &nbsp;4 +-<br>
&nbsp;drivers/net/fs_enet/mii-fec.c &nbsp; &nbsp; &nbsp;| &nbsp; 23 +++++++-----<br>
&nbsp;7 files changed, 95 insertions(+), 77 deletions(-)<br>
</blockquote>
<br></div>
patch does not apply<div><div></div><div class="Wj3C7c"><br>
<br>
<br>
_______________________________________________<br>
Linuxppc-dev mailing list<br>
<a href="mailto:Linuxppc-dev@ozlabs.org" target="_blank">Linuxppc-dev@ozlabs.org</a><br>
<a href="https://ozlabs.org/mailman/listinfo/linuxppc-dev" target="_blank">https://ozlabs.org/mailman/listinfo/linuxppc-dev</a><br>
</div></div></blockquote></div><br>

------=_Part_18767_19192528.1213762355533--

--===============1146093477==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Linuxppc-dev mailing list
Linuxppc-dev@ozlabs.org
https://ozlabs.org/mailman/listinfo/linuxppc-dev
--===============1146093477==--
