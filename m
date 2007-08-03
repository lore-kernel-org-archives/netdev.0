From: "Joachim Deguara" <joachim.deguara@amd.com>
Subject: Re: [REGRESSION] tg3 dead after s2ram
Date: Fri, 3 Aug 2007 11:47:37 +0200
Message-ID: <200708031147.38519.joachim.deguara@amd.com>
References: <1186002023.18322.7.camel@dell>
 <20070802.022317.66176729.davem@davemloft.net>
 <1186081829.18322.20.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David Miller" <davem@davemloft.net>, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, michal.k.k.piotrowski@gmail.com,
	"netdev" <netdev@vger.kernel.org>, linux-acpi@vger.kernel.org
To: "Michael Chan" <mchan@broadcom.com>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <1186081829.18322.20.camel@dell>
Content-Disposition: inline
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 02 August 2007 21:10:29 Michael Chan wrote:
> Alternatively, we can also fix it by calling pci_enable_device() agai=
n
> in tg3_open(). =C2=A0But I think it is better to just always save and=
 restore
> in suspend/resume. =C2=A0bnx2.c will also require the same fix.
>
> Thanks Joachim for helping to debug this problem. =C2=A0Please try th=
is
> patch:

Patch works for me.


-Joachim



-
To unsubscribe from this list: send the line "unsubscribe linux-acpi" i=
n
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
