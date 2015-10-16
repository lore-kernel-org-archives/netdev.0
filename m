From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH] ipv6: no addrconf for slave devices
Date: Fri, 16 Oct 2015 10:02:47 -0600
Message-ID: <56211FA7.6020107@cumulusnetworks.com>
References: <1444990911-27458-1-git-send-email-jblunck@infradead.org>
 <20151016115457.GE2194@nanopsycho.orion>
 <CALe+Z02xUZEeRMBfTneJaGFH0TQFoQt9WcJ67ogbQwXEs6p8Ew@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	jmorris@namei.org, yoshfuji@linux-ipv6.org,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>, fubar@us.ibm.com
To: Jan Blunck <jblunck@infradead.org>, Jiri Pirko <jiri@resnulli.us>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CALe+Z02xUZEeRMBfTneJaGFH0TQFoQt9WcJ67ogbQwXEs6p8Ew@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/16/15 9:57 AM, Jan Blunck wrote:
>
> I don't think that enslaved ports should get network layer addresses.
> This is one example with a team device:

for VRF devices we do want the enslaved links to have link local addresses.
