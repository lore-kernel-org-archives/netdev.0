From: Wei Wang <weiwan@google.com>
Subject: Re: unregister_netdevice: waiting for eth0 to become free. Usage
 count = 1
Date: Sat, 12 Aug 2017 12:29:54 -0700
Message-ID: <CAEA6p_BccA3ZRrhsfT3=4FNLgD_55o-LEqj5BU2onu4HnqCPfA@mail.gmail.com>
References: <CALAqxLWVYgnTnwAwm7uNQ6P_Z8xFd96NQ+G_j1qT+h5F6habag@mail.gmail.com>
 <CALAqxLXG8X2nkLEHM63oiY=M17vcpU2+-ec7x_aBWDCqrj4U-Q@mail.gmail.com>
 <CAM_iQpW2=aKKUmWanbuhqXdZGxr_TqB5pQ+U+A0+=optuGX5-Q@mail.gmail.com>
 <CALAqxLXv60ReJu26omM6p=ZboEm-Z-3w+q0JcxLXDqqK5ohNoQ@mail.gmail.com>
 <CAEA6p_AL8uUghtZgp4OmqygcFs-Jiy286P5r6tRd+yeSWxR3KA@mail.gmail.com>
 <CALAqxLXY-kE2N__eDq514cLycR0-QRpyOCMWpdttO6fgovE2rg@mail.gmail.com>
 <CAEA6p_C_rEYkJhcniyy6HUHgNxWFoxWzZ-WHsaSmNDwx4D+RXQ@mail.gmail.com>
 <CAEA6p_AOcNkAWPc7NFBnr8QWi3eHdJiQ2=8D_DB_XthwSDL2+Q@mail.gmail.com>
 <CALAqxLUoV6EQvofTEv9whW1_QMPBPU7eJBhRFUjaSs7CGeRFww@mail.gmail.com>
 <CAM_iQpWMWg5ytDq2Y9p9uet1zowGuCX+eksyiyxu9vQ18WoPxQ@mail.gmail.com>
 <CAEA6p_CooRGNOQN3fosF0JLqmd9aOTuNHKNPE8cbrzDH6c176w@mail.gmail.com>
 <CAEA6p_COwXWP97wSHvzokmm8ckQ2QEd7=dfNH04ttDPm_z3bcg@mail.gmail.com>
 <a2a0f380-3e49-8772-dde9-bcebd94cd7fd@gmail.com> <CAEA6p_CxiwXzQHgLA_Oma0pfayYReGc5QmJkV=Td9M1Kdqwbzg@mail.gmail.com>
 <ddebbddc-bb66-ed0f-423a-277d40f99f66@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        John Stultz <john.stultz@linaro.org>,
        Martin KaFai Lau <kafai@fb.com>,
        lkml <linux-kernel@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        Linux USB List <linux-usb@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Felipe Balbi <felipe.balbi@linux.intel.com>
To: David Ahern <dsahern@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <ddebbddc-bb66-ed0f-423a-277d40f99f66@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 11, 2017 at 8:37 PM, David Ahern <dsahern@gmail.com> wrote:
> On 8/11/17 6:25 PM, Wei Wang wrote:
>> By "a patch to fix that" do you mean after your patch, for every rt6,
>> rt6->rt6i_idev will be the same as rt6->dst.dev?
>
> FIB entries should have them the same device with my patch.
>
> The copies done (ip6_rt_cache_alloc and ip6_rt_pcpu_alloc) will have to
> set dst.dev to loopback or VRF device for RTF_LOCAL routes; it's the
> only way to get local traffic to work and this is similar to what IPv4 does.

Got it. Thanks David.

Wei
