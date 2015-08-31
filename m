From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH 2/2] usbnet: Fix a race between usbnet_stop() and the BH
Date: Mon, 31 Aug 2015 09:32:54 +0200
Message-ID: <87io7vzzdl.fsf@nemi.mork.no>
References: <55AD3A41.2040100@rosalab.ru>
	<1440447223-15945-1-git-send-email-eugene.shatokhin@rosalab.ru>
	<1440447223-15945-3-git-send-email-eugene.shatokhin@rosalab.ru>
	<87k2sk9zaf.fsf@nemi.mork.no> <55E01750.4010202@rosalab.ru>
	<87mvxbzta9.fsf@nemi.mork.no> <55E03B28.6050305@rosalab.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Oliver Neukum <oneukum@suse.de>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org
To: Eugene Shatokhin <eugene.shatokhin@rosalab.ru>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55E03B28.6050305@rosalab.ru> (Eugene Shatokhin's message of
	"Fri, 28 Aug 2015 13:42:48 +0300")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eugene Shatokhin <eugene.shatokhin@rosalab.ru> writes:
> 28.08.2015 11:55, Bj=C3=B8rn Mork =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
>
>> I guess you are right.  At least I cannot prove that you are not :)
>>
>> There is a bit too much complexity involved here for me...
>
> :-)
>
> Yes, it is quite complex.
>
> I admit, it was easier for me to find the races in usbnet (the tools
> like KernelStrider and RaceHound do the dirty work) than to analyze
> their consequences. The latter often requires some time and effort,
> and so it did this time.
>
> Well, any objections to this patch?

No objections from me.

But I would have liked it much better if the code became simpler instea=
d
of more complex.


Bj=C3=B8rn
