From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/2] net: tcp_header_len_th and tcp_option_len_th
Date: Tue, 12 Jan 2010 18:53:22 +0100
Message-ID: <4B4CB712.8030806@gmail.com>
References: <4B44FE3C.6060809@gmail.com> <4B450065.4010108@gmail.com> <4B4C519E.2090207@gmail.com> <4B4CB46C.8020502@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Michael Chan <mchan@broadcom.com>
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754049Ab0ALRxb@vger.kernel.org>
In-Reply-To: <4B4CB46C.8020502@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 12/01/2010 18:42, William Allen Simpson a =E9crit :
> Eric Dumazet wrote:
>> Its better to inline your patches so that we can comment them, witho=
ut
>> copy/paste
>>
>> When I hit 'reply to', my mailer only quoted the ChangeLog, not the
>> patch.
>>
> Seeing that we're both using Mozilla, how to you do it?
>=20
> It took me many attempts to get this to work with Thunderbird on the =
Mac.
>=20

Hmm, I followed Documentation/email-clients.txt tricks, I dont remember=
 exact details.

I type my Changelog text, add my signature, then copy/paste patch from =
external editor
(this editor must preserve tabulations of course)

Its probably a bit odd, because I am stuck with a windows XP notebook h=
ere at work,
dont flame me :(



About cast games, maybe following way is the cleanest one.

int tcp_options_len_th(struct tcphdr *th)
{
	return tcp_header_len_th(th) - sizeof(*th);
}
