From: Julian Calaby <julian.calaby@gmail.com>
Subject: Re: [PATCHv4 3/4] sparc64: Avoid irqsave/restore on vio.lock if in_softirq()
Date: Wed, 22 Oct 2014 09:42:13 +1100
Message-ID: <CAGRGNgWev1kouJUx2JmPn6V+pvJ0ccE+TCMX=YVaBvAFRDFyQw@mail.gmail.com>
References: <20141021141647.GF15405@oracle.com> <CAGRGNgXvKJBhOE1z3=_gZkE=X94HnoAvTN6Zv5G1h8JuFfS8Ng@mail.gmail.com>
 <20141021223952.GA26724@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	sparclinux <sparclinux@vger.kernel.org>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <sparclinux-owner@vger.kernel.org>
In-Reply-To: <20141021223952.GA26724@oracle.com>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Sowmini,

On Wed, Oct 22, 2014 at 9:39 AM, Sowmini Varadhan
<sowmini.varadhan@oracle.com> wrote:
> On (10/22/14 09:35), Julian Calaby wrote:
>> >  void vio_port_up(struct vio_driver_state *vio)
>> >  {
>> > -       unsigned long flags;
>> > +       unsigned long flags = 0;
>>
>> Is gcc not smart enough to know that this variable isn't used before
>> it's set? (I assume it isn't used elsewhere in this function)
>
> No, it's not used elsewhere in the function, and yes, I too was
> surprised by the build warning, which is why I initialized it
> as above.

Ok, fair enough then.

Thanks,

-- 
Julian Calaby

Email: julian.calaby@gmail.com
Profile: http://www.google.com/profiles/julian.calaby/
