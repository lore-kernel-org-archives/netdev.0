From: Xiang Gao <qasdfgtyuiop@gmail.com>
Subject: Re: [lkp-robot] [mac80211] 31e9170bde: hwsim.sta_dynamic_down_up.fail
Date: Thu, 28 Sep 2017 22:21:21 -0400
Message-ID: <CAMtaSwQHT0pP+YRx2WSL2kyZ__iJzrkF4jCrLBVzTjO40u4EgQ@mail.gmail.com>
References: <20170924054015.8958-1-qasdfgtyuiop@gmail.com> <20170928080614.GZ17200@yexl-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        "David S. Miller" <davem@davemloft.net>,
        Johannes Berg <johannes@sipsolutions.net>,
        linux-crypto@vger.kernel.org,
        linux-kernel <linux-kernel@vger.kernel.org>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org, lkp@01.org
To: kernel test robot <xiaolong.ye@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170928080614.GZ17200@yexl-desktop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks, I will look into it.
Xiang Gao


2017-09-28 4:06 GMT-04:00 kernel test robot <xiaolong.ye@intel.com>:
>
> FYI, we noticed the following commit:
>
> commit: 31e9170bdeb6ebe66426337b4e2b9924683a412b ("mac80211: aead api to reduce redundancy")
> url: https://github.com/0day-ci/linux/commits/Xiang-Gao/mac80211-aead-api-to-reduce-redundancy/20170926-053110
> base: https://git.kernel.org/cgit/linux/kernel/git/jberg/mac80211-next.git master
>
> in testcase: hwsim
> with following parameters:
>
>         group: hwsim-10
>
>
>
> on test machine: qemu-system-x86_64 -enable-kvm -cpu host -smp 2 -m 2G
>
> caused below changes (please refer to attached dmesg/kmsg for entire log/backtrace):
>
>
> 2017-09-27 16:04:27     ./run-tests.py sta_dynamic_down_up
> DEV: wlan0: 02:00:00:00:00:00
> DEV: wlan1: 02:00:00:00:01:00
> DEV: wlan2: 02:00:00:00:02:00
> APDEV: wlan3
> APDEV: wlan4
> START sta_dynamic_down_up 1/1
> Test: Dynamically added wpa_supplicant interface down/up
> Starting AP wlan3
> Create a dynamic wpa_supplicant interface and connect
> Connect STA wlan5 to AP
> dev1->dev2 unicast data delivery failed
> Traceback (most recent call last):
>   File "./run-tests.py", line 453, in main
>     t(dev, apdev)
>   File "/lkp/benchmarks/hwsim/tests/hwsim/test_sta_dynamic.py", line 122, in test_sta_dynamic_down_up
>     hwsim_utils.test_connectivity(wpas, hapd)
>   File "/lkp/benchmarks/hwsim/tests/hwsim/hwsim_utils.py", line 165, in test_connectivity
>     raise Exception(last_err)
> Exception: dev1->dev2 unicast data delivery failed
> FAIL sta_dynamic_down_up 5.397413 2017-09-27 16:04:32.540689
> passed 0 test case(s)
> skipped 0 test case(s)
> failed tests: sta_dynamic_down_up
>
>
>
> To reproduce:
>
>         git clone https://github.com/intel/lkp-tests.git
>         cd lkp-tests
>         bin/lkp qemu -k <bzImage> job-script  # job-script is attached in this email
>
>
>
> Thanks,
> Xiaolong
