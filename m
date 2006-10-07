From: Alex Romosan <romosan@sycorax.lbl.gov>
Subject: Re: 2.6.19-rc1 regression: airo suspend fails
Date: Fri, 06 Oct 2006 20:54:59 -0700
Message-ID: <87y7rszsoc.fsf@sycorax.lbl.gov>
References: <Pine.LNX.4.64.0610042017340.3952@g5.osdl.org>
	<871wpmoyjv.fsf@sycorax.lbl.gov> <20061006184706.GR16812@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, linux-pm@osdl.org, linux-kernel@vger.kernel.org
Return-path: <linux-pm-bounces@lists.osdl.org>
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20061006184706.GR16812@stusta.de> (message from Adrian Bunk on
	Fri, 6 Oct 2006 20:47:07 +0200)
List-Unsubscribe: <https://lists.osdl.org/mailman/listinfo/linux-pm>,
	<mailto:linux-pm-request@lists.osdl.org?subject=unsubscribe>
List-Archive: <http://lists.osdl.org/pipermail/linux-pm>
List-Post: <mailto:linux-pm@lists.osdl.org>
List-Help: <mailto:linux-pm-request@lists.osdl.org?subject=help>
List-Subscribe: <https://lists.osdl.org/mailman/listinfo/linux-pm>,
	<mailto:linux-pm-request@lists.osdl.org?subject=subscribe>
Sender: linux-pm-bounces@lists.osdl.org
Errors-To: linux-pm-bounces@lists.osdl.org
List-Id: netdev.vger.kernel.org

Adrian Bunk <bunk@stusta.de> writes:

> On Thu, Oct 05, 2006 at 09:31:16PM -0700, Alex Romosan wrote:
>> Linus Torvalds <torvalds@osdl.org> writes:
>> =

>> > so please give it a good testing, and let's see if there are any =

>> > regressions.
>> =

>> it breaks suspend when the airo module is loaded:
>> =

>> kernel: Stopping tasks: =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> kernel:  stopping tasks timed out after 20 seconds (1 tasks remaining):
>> kernel:   eth1
>> kernel: Restarting tasks...<6> Strange, eth1 not stopped
>> =

>> if i remove the airo module suspend works normally (this is on a
>> thinkpad t40).
>
> Thanks for your report.
>
> Let's try to figure out what broke it.
>
> As a first step, please replace drivers/net/wireless/airo.c with the =

> version in 2.6.18 and check whether this fixes the issue (you can ignore =

> the deprecated warning during compilation).

i replaced airo.c with the 2.6.18 version. the good news is i can
suspend to memory with it. the bad news is dhcp never got an ip
address (so i don't think the 2.6.18 driver really works with the
2.6.19-rc1 infrastructure). any patches i could try? thanks.

--alex--

-- =

| I believe the moment is at hand when, by a paranoiac and active |
|  advance of the mind, it will be possible (simultaneously with  |
|  automatism and other passive states) to systematize confusion  |
|  and thus to help to discredit completely the world of reality. |
