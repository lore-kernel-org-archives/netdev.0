From: =?iso-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>
Subject: Re: [RFC PATCH v2 0/2] nb8800 suspend/resume support
Date: Wed, 02 Aug 2017 17:10:06 +0100
Message-ID: <yw1xk22mgdcx.fsf@mansr.com>
References: <33d1ab47-6098-5e3f-8a3c-f72626d07113@free.fr>
 <aa8885b8-e6bb-3624-2bf9-0bb40505ac54@free.fr>
 <dd883398-1511-0bfd-972b-a11ef8709f0d@free.fr>
 <yw1xshhagexd.fsf@mansr.com>
 <9e8e12b1-74e2-8323-ec16-eebda46b2a3d@free.fr>
 <yw1xo9rygdyu.fsf@mansr.com>
 <6906dccf-bec9-0fc8-a34a-c39c05ada917@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: netdev <netdev@vger.kernel.org>, Florian Fainelli <f.fainelli@gmail.com>,
 David Miller <davem@davemloft.net>,
 Linux ARM <linux-arm-kernel@lists.infradead.org>
To: Mason <slash.tmp@free.fr>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <6906dccf-bec9-0fc8-a34a-c39c05ada917@free.fr> (Mason's message
 of "Wed, 2 Aug 2017 18:07:52 +0200")
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Mason <slash.tmp@free.fr> writes:

> On 02/08/2017 17:56, M=E5ns Rullg=E5rd wrote:
>
>> Mason writes:
>> =

>>> From my perspective, the older method does not work on newer chips :-)
>> =

>> It does work on tango4.
>
> Agreed.
>
>> What does the tango5 do if you flood it with packets faster than the
>> kernel can keep up with?  That would make it hit the end of the rx
>> chain, which is apparently what makes it miserable with the current dma
>> stop code.
>
> The simplest way to test this would be sending tiny packets
> as fast as possible, right? So ping -f on a GigE link should
> fit the bill?

ping -f is limited to 100 packets per second.  Use something like iperf
in UDP mode instead.

-- =

M=E5ns Rullg=E5rd
