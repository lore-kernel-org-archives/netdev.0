From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH v2] sctp: don't dereference ptr before leaving
 _sctp_walk_{params,errors}()
Date: Sat, 15 Jul 2017 04:22:50 +0800
Message-ID: <201707150430.oMuMHtoP%fengguang.wu@intel.com>
References: <20170714100329.105604-1-glider@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, dvyukov@google.com, kcc@google.com,
        edumazet@google.com, davem@davemloft.net, lucien.xin@gmail.com,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Alexander Potapenko <glider@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170714100329.105604-1-glider@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Alexander,

[auto build test WARNING on net-next/master]
[also build test WARNING on next-20170714]
[cannot apply to v4.12]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Alexander-Potapenko/sctp-don-t-dereference-ptr-before-leaving-_sctp_walk_-params-errors/20170715-013318
reproduce:
        # apt-get install sparse
        make ARCH=x86_64 allmodconfig
        make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

   include/linux/compiler.h:260:8: sparse: attribute 'no_sanitize_address': unknown attribute
   net/sctp/sm_statefuns.c:3871:9: sparse: Expected , in __builtin_offset
   net/sctp/sm_statefuns.c:3871:9: sparse: got sctp_paramhdr_t
>> builtin:0:0: sparse: No right hand side of '+'-expression
   net/sctp/sm_statefuns.c:3871:9: sparse: Expected ) in 'for'
   net/sctp/sm_statefuns.c:3871:9: sparse: got ;
   net/sctp/sm_statefuns.c:3871:9: sparse: Expected ; at end of statement
   net/sctp/sm_statefuns.c:3871:9: sparse: got )
>> net/sctp/sm_statefuns.c:3903:9: sparse: Trying to use reserved word 'return' as identifier
   net/sctp/sm_statefuns.c:3903:16: sparse: Expected ; at end of declaration
   net/sctp/sm_statefuns.c:3903:16: sparse: got SCTP_DISPOSITION_CONSUME
   net/sctp/sm_statefuns.c:3904:1: sparse: Expected ; at the end of type declaration
   net/sctp/sm_statefuns.c:3904:1: sparse: got }
   net/sctp/sm_statefuns.c:3933:13: sparse: Expected ) in function declarator
   net/sctp/sm_statefuns.c:3933:13: sparse: got !
>> net/sctp/sm_statefuns.c:3933:9: sparse: Trying to use reserved word 'if' as identifier
   net/sctp/sm_statefuns.c:3936:17: sparse: Trying to use reserved word 'return' as identifier
   net/sctp/sm_statefuns.c:3936:24: sparse: Expected ; at end of declaration
   net/sctp/sm_statefuns.c:3936:24: sparse: got sctp_sf_pdiscard
   net/sctp/sm_statefuns.c:3937:9: sparse: Expected ; at the end of type declaration
   net/sctp/sm_statefuns.c:3937:9: sparse: got }
   net/sctp/sm_statefuns.c:3943:13: sparse: Expected ) in function declarator
   net/sctp/sm_statefuns.c:3943:13: sparse: got !
   net/sctp/sm_statefuns.c:3943:9: sparse: Trying to use reserved word 'if' as identifier
   net/sctp/sm_statefuns.c:3948:14: sparse: Expected ; at end of declaration
   net/sctp/sm_statefuns.c:3948:14: sparse: got ->
   net/sctp/sm_statefuns.c:3950:13: sparse: Expected ; at end of declaration
   net/sctp/sm_statefuns.c:3950:13: sparse: got -=
   net/sctp/sm_statefuns.c:3951:23: sparse: Expected ) in function declarator
   net/sctp/sm_statefuns.c:3951:23: sparse: got ->
>> net/sctp/sm_statefuns.c:3954:9: sparse: Trying to use reserved word 'do' as identifier
   net/sctp/sm_statefuns.c:3954:9: sparse: Expected ; at end of declaration
   net/sctp/sm_statefuns.c:3954:9: sparse: got {
   net/sctp/sm_statefuns.c:3954:9: sparse: Expected ) in function declarator
   net/sctp/sm_statefuns.c:3954:9: sparse: got (
   net/sctp/sm_statefuns.c:3954:9: sparse: Trying to use reserved word 'if' as identifier
   net/sctp/sm_statefuns.c:3954:9: sparse: Expected ) in function declarator
   net/sctp/sm_statefuns.c:3954:9: sparse: got (
   net/sctp/sm_statefuns.c:3954:9: sparse: Trying to use reserved word 'if' as identifier
>> net/sctp/sm_statefuns.c:3954:9: sparse: Trying to use reserved word 'else' as identifier
   net/sctp/sm_statefuns.c:3954:9: sparse: Expected ; at end of declaration
   net/sctp/sm_statefuns.c:3954:9: sparse: got if
>> net/sctp/sm_statefuns.c:3954:9: sparse: Trying to use reserved word 'else' as identifier
   net/sctp/sm_statefuns.c:3954:9: sparse: Expected ; at end of declaration
   net/sctp/sm_statefuns.c:3954:9: sparse: got branch
   net/sctp/sm_statefuns.c:3954:9: sparse: Expected ; at the end of type declaration
   net/sctp/sm_statefuns.c:3954:9: sparse: got }
   net/sctp/sm_statefuns.c:3954:9: sparse: Expected ; at the end of type declaration
   net/sctp/sm_statefuns.c:3954:9: sparse: got }
   net/sctp/sm_statefuns.c:3959:30: sparse: Expected ) in function declarator
   net/sctp/sm_statefuns.c:3959:30: sparse: got (
   net/sctp/sm_statefuns.c:3959:9: sparse: Trying to use reserved word 'if' as identifier
   net/sctp/sm_statefuns.c:3963:9: sparse: Expected ) in function declarator
   net/sctp/sm_statefuns.c:3963:9: sparse: got (
>> net/sctp/sm_statefuns.c:3963:9: sparse: Trying to use reserved word 'for' as identifier
   net/sctp/sm_statefuns.c:3963:9: sparse: Expected ) in nested declarator
   net/sctp/sm_statefuns.c:3963:9: sparse: got *
>> net/sctp/sm_statefuns.c:3963:9: sparse: Trying to use reserved word 'void' as identifier
   net/sctp/sm_statefuns.c:3963:9: sparse: Expected ; at end of declaration
   net/sctp/sm_statefuns.c:3963:9: sparse: got ++
   net/sctp/sm_statefuns.c:3966:9: sparse: Expected ; at the end of type declaration
   net/sctp/sm_statefuns.c:3966:9: sparse: got }
   net/sctp/sm_statefuns.c:3969:17: sparse: Expected ) in function declarator
   net/sctp/sm_statefuns.c:3969:17: sparse: got >
   net/sctp/sm_statefuns.c:3969:9: sparse: Trying to use reserved word 'if' as identifier
   net/sctp/sm_statefuns.c:3974:17: sparse: Expected ) in function declarator
   net/sctp/sm_statefuns.c:3974:17: sparse: got ->
   net/sctp/sm_statefuns.c:3974:9: sparse: Trying to use reserved word 'if' as identifier
   net/sctp/sm_statefuns.c:3977:9: sparse: Expected ; at the end of type declaration
   net/sctp/sm_statefuns.c:3977:9: sparse: got }
   net/sctp/sm_statefuns.c:3984:9: sparse: Trying to use reserved word 'return' as identifier
   net/sctp/sm_statefuns.c:3984:16: sparse: Expected ; at end of declaration
   net/sctp/sm_statefuns.c:3984:16: sparse: got SCTP_DISPOSITION_CONSUME
   net/sctp/sm_statefuns.c:3986:16: sparse: Expected ; at end of declaration
   net/sctp/sm_statefuns.c:3986:16: sparse: got :
   net/sctp/sm_statefuns.c:3988:1: sparse: Expected ; at the end of type declaration
   net/sctp/sm_statefuns.c:3988:1: sparse: got }
   net/sctp/sm_statefuns.c:4004:13: sparse: Expected ) in function declarator
   net/sctp/sm_statefuns.c:4004:13: sparse: got !
   net/sctp/sm_statefuns.c:4004:9: sparse: Trying to use reserved word 'if' as identifier
   net/sctp/sm_statefuns.c:4007:17: sparse: Trying to use reserved word 'return' as identifier
   net/sctp/sm_statefuns.c:4007:24: sparse: Expected ; at end of declaration
   net/sctp/sm_statefuns.c:4007:24: sparse: got sctp_sf_pdiscard
   net/sctp/sm_statefuns.c:4008:9: sparse: Expected ; at the end of type declaration
   net/sctp/sm_statefuns.c:4008:9: sparse: got }
   net/sctp/sm_statefuns.c:4014:13: sparse: Expected ) in function declarator
   net/sctp/sm_statefuns.c:4014:13: sparse: got !
   net/sctp/sm_statefuns.c:4014:9: sparse: Trying to use reserved word 'if' as identifier
   net/sctp/sm_statefuns.c:4019:14: sparse: Expected ; at end of declaration
   net/sctp/sm_statefuns.c:4019:14: sparse: got ->
   net/sctp/sm_statefuns.c:4021:13: sparse: Expected ; at end of declaration
   net/sctp/sm_statefuns.c:4021:13: sparse: got -=
   net/sctp/sm_statefuns.c:4022:23: sparse: Expected ) in function declarator
   net/sctp/sm_statefuns.c:4022:23: sparse: got ->
   net/sctp/sm_statefuns.c:4025:9: sparse: Trying to use reserved word 'do' as identifier
   net/sctp/sm_statefuns.c:4025:9: sparse: Expected ; at end of declaration
   net/sctp/sm_statefuns.c:4025:9: sparse: got {
   net/sctp/sm_statefuns.c:4025:9: sparse: Expected ) in function declarator
   net/sctp/sm_statefuns.c:4025:9: sparse: got (
   net/sctp/sm_statefuns.c:4025:9: sparse: Trying to use reserved word 'if' as identifier
   net/sctp/sm_statefuns.c:4025:9: sparse: Expected ) in function declarator
>> net/sctp/sm_statefuns.c:4025:9: sparse: too many errors
   In file included from include/linux/compiler.h:58:0,
                    from include/uapi/linux/stddef.h:1,
                    from include/linux/stddef.h:4,
                    from include/uapi/linux/posix_types.h:4,
                    from include/uapi/linux/types.h:13,
                    from include/linux/types.h:5,
                    from net/sctp/sm_statefuns.c:48:
   net/sctp/sm_statefuns.c: In function 'sctp_sf_do_reconf':
   include/net/sctp/sctp.h:472:24: error: unknown type name 'sctp_paramhdr_t'
         (pos.v + offsetof(sctp_paramhdr_t, length) + sizeof(pos.p->length) <\
                           ^
   include/linux/compiler-gcc.h:161:21: note: in definition of macro '__compiler_offsetof'
     __builtin_offsetof(a, b)
                        ^
   include/net/sctp/sctp.h:472:15: note: in expansion of macro 'offsetof'
         (pos.v + offsetof(sctp_paramhdr_t, length) + sizeof(pos.p->length) <\
                  ^~~~~~~~
   include/net/sctp/sctp.h:468:1: note: in expansion of macro '_sctp_walk_params'
    _sctp_walk_params((pos), (chunk), ntohs((chunk)->chunk_hdr.length), member)
    ^~~~~~~~~~~~~~~~~
   net/sctp/sm_statefuns.c:3871:2: note: in expansion of macro 'sctp_walk_params'
     sctp_walk_params(param, hdr, params) {
     ^~~~~~~~~~~~~~~~
--
   include/linux/compiler.h:260:8: sparse: attribute 'no_sanitize_address': unknown attribute
   net/sctp/sm_make_chunk.c:2262:9: sparse: Expected , in __builtin_offset
   net/sctp/sm_make_chunk.c:2262:9: sparse: got sctp_paramhdr_t
>> builtin:0:0: sparse: No right hand side of '+'-expression
   net/sctp/sm_make_chunk.c:2262:9: sparse: Expected ) in 'for'
   net/sctp/sm_make_chunk.c:2262:9: sparse: got ;
   net/sctp/sm_make_chunk.c:2262:9: sparse: Expected ; at end of statement
   net/sctp/sm_make_chunk.c:2262:9: sparse: got )
   net/sctp/sm_make_chunk.c:2274:18: sparse: Expected ) in function declarator
   net/sctp/sm_make_chunk.c:2274:18: sparse: got .
>> net/sctp/sm_make_chunk.c:2274:9: sparse: Trying to use reserved word 'if' as identifier
   net/sctp/sm_make_chunk.c:2280:13: sparse: Expected ) in function declarator
   net/sctp/sm_make_chunk.c:2280:13: sparse: got (
   net/sctp/sm_make_chunk.c:2280:9: sparse: Trying to use reserved word 'if' as identifier
   net/sctp/sm_make_chunk.c:2285:9: sparse: Expected ) in function declarator
   net/sctp/sm_make_chunk.c:2285:9: sparse: got (
>> net/sctp/sm_make_chunk.c:2285:9: sparse: Trying to use reserved word 'for' as identifier
   net/sctp/sm_make_chunk.c:2285:9: sparse: Expected ) in nested declarator
   net/sctp/sm_make_chunk.c:2285:9: sparse: got .
   net/sctp/sm_make_chunk.c:2285:9: sparse: Expected ; at end of declaration
   net/sctp/sm_make_chunk.c:2285:9: sparse: got .
>> net/sctp/sm_make_chunk.c:2288:17: sparse: Trying to use reserved word 'switch' as identifier
>> net/sctp/sm_make_chunk.c:2289:17: sparse: not in switch scope
   net/sctp/sm_make_chunk.c:2290:17: sparse: not in switch scope
   net/sctp/sm_make_chunk.c:2292:17: sparse: not in switch scope
   net/sctp/sm_make_chunk.c:2294:17: sparse: not in switch scope
   net/sctp/sm_make_chunk.c:2295:17: sparse: not in switch scope
>> net/sctp/sm_make_chunk.c:2296:25: sparse: break/continue not in iterator scope
   net/sctp/sm_make_chunk.c:2299:9: sparse: Expected ; at the end of type declaration
   net/sctp/sm_make_chunk.c:2299:9: sparse: got }
   net/sctp/sm_make_chunk.c:2302:1: sparse: Expected ; at the end of type declaration
   net/sctp/sm_make_chunk.c:2302:1: sparse: got }
   net/sctp/sm_make_chunk.c:2331:13: sparse: Expected ) in function declarator
   net/sctp/sm_make_chunk.c:2331:13: sparse: got !
   net/sctp/sm_make_chunk.c:2331:9: sparse: Trying to use reserved word 'if' as identifier
   net/sctp/sm_make_chunk.c:2334:32: sparse: Expected ) in function declarator
   net/sctp/sm_make_chunk.c:2334:32: sparse: got (
   net/sctp/sm_make_chunk.c:2334:9: sparse: Trying to use reserved word 'if' as identifier
   net/sctp/sm_make_chunk.c:2338:9: sparse: Expected ) in function declarator
   net/sctp/sm_make_chunk.c:2338:9: sparse: got (
   net/sctp/sm_make_chunk.c:2338:9: sparse: Trying to use reserved word 'for' as identifier
   net/sctp/sm_make_chunk.c:2338:9: sparse: Expected ) in nested declarator
   net/sctp/sm_make_chunk.c:2338:9: sparse: got .
   net/sctp/sm_make_chunk.c:2338:9: sparse: Expected ; at end of declaration
   net/sctp/sm_make_chunk.c:2338:9: sparse: got .
   net/sctp/sm_make_chunk.c:2342:27: sparse: Expected ; at end of declaration
   net/sctp/sm_make_chunk.c:2342:27: sparse: got ->
   net/sctp/sm_make_chunk.c:2344:48: sparse: Expected ) in function declarator
   net/sctp/sm_make_chunk.c:2344:48: sparse: got (
   net/sctp/sm_make_chunk.c:2344:25: sparse: Trying to use reserved word 'if' as identifier
   net/sctp/sm_make_chunk.c:2346:17: sparse: Expected ; at the end of type declaration
   net/sctp/sm_make_chunk.c:2346:17: sparse: got }
   net/sctp/sm_make_chunk.c:2350:9: sparse: Expected ; at the end of type declaration
   net/sctp/sm_make_chunk.c:2350:9: sparse: got }
   net/sctp/sm_make_chunk.c:2359:17: sparse: Expected ) in function declarator
   net/sctp/sm_make_chunk.c:2359:17: sparse: got ->
   net/sctp/sm_make_chunk.c:2359:9: sparse: Trying to use reserved word 'if' as identifier
   net/sctp/sm_make_chunk.c:2369:13: sparse: Expected ) in function declarator
   net/sctp/sm_make_chunk.c:2369:13: sparse: got !
   net/sctp/sm_make_chunk.c:2369:9: sparse: Trying to use reserved word 'if' as identifier
   net/sctp/sm_make_chunk.c:2374:21: sparse: Expected ; at end of declaration
   net/sctp/sm_make_chunk.c:2374:21: sparse: got ->
>> net/sctp/sm_make_chunk.c:2375:17: sparse: Trying to use reserved word 'goto' as identifier
   net/sctp/sm_make_chunk.c:2375:22: sparse: Expected ; at end of declaration
   net/sctp/sm_make_chunk.c:2375:22: sparse: got clean_up
   net/sctp/sm_make_chunk.c:2376:9: sparse: Expected ; at the end of type declaration
   net/sctp/sm_make_chunk.c:2376:9: sparse: got }
   net/sctp/sm_make_chunk.c:2379:9: sparse: Expected ; at end of declaration
   net/sctp/sm_make_chunk.c:2379:9: sparse: got !=
   net/sctp/sm_make_chunk.c:2379:9: sparse: Expected ; at end of declaration
   net/sctp/sm_make_chunk.c:2379:9: sparse: got )
   net/sctp/sm_make_chunk.c:2380:29: sparse: Expected ) in nested declarator
   net/sctp/sm_make_chunk.c:2380:29: sparse: got sctp_transport
>> net/sctp/sm_make_chunk.c:2380:29: sparse: Trying to use reserved word 'struct' as identifier
   net/sctp/sm_make_chunk.c:2380:29: sparse: Expected ; at the end of type declaration
   net/sctp/sm_make_chunk.c:2380:29: sparse: got }
   net/sctp/sm_make_chunk.c:2381:30: sparse: Expected ) in function declarator
   net/sctp/sm_make_chunk.c:2381:30: sparse: got ->
   net/sctp/sm_make_chunk.c:2381:17: sparse: Trying to use reserved word 'if' as identifier
   net/sctp/sm_make_chunk.c:2383:17: sparse: Expected ; at the end of type declaration
   net/sctp/sm_make_chunk.c:2383:17: sparse: got }
   net/sctp/sm_make_chunk.c:2391:13: sparse: Expected ; at end of declaration
   net/sctp/sm_make_chunk.c:2391:13: sparse: got ->
   net/sctp/sm_make_chunk.c:2393:13: sparse: Expected ; at end of declaration
   net/sctp/sm_make_chunk.c:2393:13: sparse: got ->
   net/sctp/sm_make_chunk.c:2395:13: sparse: Expected ; at end of declaration
   net/sctp/sm_make_chunk.c:2395:13: sparse: got ->
   net/sctp/sm_make_chunk.c:2397:13: sparse: Expected ; at end of declaration
   net/sctp/sm_make_chunk.c:2397:13: sparse: got ->
   net/sctp/sm_make_chunk.c:2400:13: sparse: Expected ; at end of declaration
   net/sctp/sm_make_chunk.c:2400:13: sparse: got ->
   net/sctp/sm_make_chunk.c:2405:17: sparse: Expected ) in function declarator
   net/sctp/sm_make_chunk.c:2405:17: sparse: got ->
   net/sctp/sm_make_chunk.c:2405:9: sparse: Trying to use reserved word 'if' as identifier
   net/sctp/sm_make_chunk.c:2409:9: sparse: Expected ; at the end of type declaration
   net/sctp/sm_make_chunk.c:2409:9: sparse: got }
   net/sctp/sm_make_chunk.c:2415:9: sparse: Expected ; at the end of type declaration
   net/sctp/sm_make_chunk.c:2415:9: sparse: got }
   net/sctp/sm_make_chunk.c:2421:13: sparse: Expected ; at end of declaration
   net/sctp/sm_make_chunk.c:2421:13: sparse: got ->
   net/sctp/sm_make_chunk.c:2425:9: sparse: Trying to use reserved word 'if' as identifier
   net/sctp/sm_make_chunk.c:2435:9: sparse: too many errors
   In file included from include/linux/compiler.h:58:0,
                    from arch/x86/include/asm/atomic.h:4,
                    from include/linux/atomic.h:4,
                    from include/linux/crypto.h:20,
                    from include/crypto/hash.h:16,
                    from net/sctp/sm_make_chunk.c:48:
   net/sctp/sm_make_chunk.c: In function 'sctp_verify_init':
   include/net/sctp/sctp.h:472:24: error: unknown type name 'sctp_paramhdr_t'
         (pos.v + offsetof(sctp_paramhdr_t, length) + sizeof(pos.p->length) <\
                           ^
   include/linux/compiler-gcc.h:161:21: note: in definition of macro '__compiler_offsetof'
     __builtin_offsetof(a, b)
                        ^
   include/net/sctp/sctp.h:472:15: note: in expansion of macro 'offsetof'
         (pos.v + offsetof(sctp_paramhdr_t, length) + sizeof(pos.p->length) <\
                  ^~~~~~~~
   include/net/sctp/sctp.h:468:1: note: in expansion of macro '_sctp_walk_params'
    _sctp_walk_params((pos), (chunk), ntohs((chunk)->chunk_hdr.length), member)
    ^~~~~~~~~~~~~~~~~
   net/sctp/sm_make_chunk.c:2262:2: note: in expansion of macro 'sctp_walk_params'
     sctp_walk_params(param, peer_init, init_hdr.params) {
     ^~~~~~~~~~~~~~~~
   include/net/sctp/sctp.h:472:24: error: unknown type name 'sctp_paramhdr_t'
         (pos.v + offsetof(sctp_paramhdr_t, length) + sizeof(pos.p->length) <\
                           ^
   include/linux/compiler-gcc.h:161:21: note: in definition of macro '__compiler_offsetof'
     __builtin_offsetof(a, b)
                        ^
   include/net/sctp/sctp.h:472:15: note: in expansion of macro 'offsetof'
         (pos.v + offsetof(sctp_paramhdr_t, length) + sizeof(pos.p->length) <\
                  ^~~~~~~~
   include/net/sctp/sctp.h:468:1: note: in expansion of macro '_sctp_walk_params'
    _sctp_walk_params((pos), (chunk), ntohs((chunk)->chunk_hdr.length), member)
    ^~~~~~~~~~~~~~~~~
   net/sctp/sm_make_chunk.c:2285:2: note: in expansion of macro 'sctp_walk_params'
     sctp_walk_params(param, peer_init, init_hdr.params) {
     ^~~~~~~~~~~~~~~~
   net/sctp/sm_make_chunk.c: In function 'sctp_process_init':
   include/net/sctp/sctp.h:472:24: error: unknown type name 'sctp_paramhdr_t'
         (pos.v + offsetof(sctp_paramhdr_t, length) + sizeof(pos.p->length) <\
                           ^
   include/linux/compiler-gcc.h:161:21: note: in definition of macro '__compiler_offsetof'
     __builtin_offsetof(a, b)
                        ^
   include/net/sctp/sctp.h:472:15: note: in expansion of macro 'offsetof'
         (pos.v + offsetof(sctp_paramhdr_t, length) + sizeof(pos.p->length) <\
                  ^~~~~~~~
   include/net/sctp/sctp.h:468:1: note: in expansion of macro '_sctp_walk_params'
    _sctp_walk_params((pos), (chunk), ntohs((chunk)->chunk_hdr.length), member)
    ^~~~~~~~~~~~~~~~~
   net/sctp/sm_make_chunk.c:2338:2: note: in expansion of macro 'sctp_walk_params'
     sctp_walk_params(param, peer_init, init_hdr.params) {
     ^~~~~~~~~~~~~~~~
   net/sctp/sm_make_chunk.c: In function 'sctp_verify_asconf':
   include/net/sctp/sctp.h:472:24: error: unknown type name 'sctp_paramhdr_t'
         (pos.v + offsetof(sctp_paramhdr_t, length) + sizeof(pos.p->length) <\
                           ^
   include/linux/compiler-gcc.h:161:21: note: in definition of macro '__compiler_offsetof'
     __builtin_offsetof(a, b)
                        ^
   include/net/sctp/sctp.h:472:15: note: in expansion of macro 'offsetof'
         (pos.v + offsetof(sctp_paramhdr_t, length) + sizeof(pos.p->length) <\
                  ^~~~~~~~
   include/net/sctp/sctp.h:468:1: note: in expansion of macro '_sctp_walk_params'
    _sctp_walk_params((pos), (chunk), ntohs((chunk)->chunk_hdr.length), member)
    ^~~~~~~~~~~~~~~~~
   net/sctp/sm_make_chunk.c:3148:2: note: in expansion of macro 'sctp_walk_params'
     sctp_walk_params(param, addip, addip_hdr.params) {
     ^~~~~~~~~~~~~~~~
   net/sctp/sm_make_chunk.c: In function 'sctp_process_asconf':
   include/net/sctp/sctp.h:472:24: error: unknown type name 'sctp_paramhdr_t'
         (pos.v + offsetof(sctp_paramhdr_t, length) + sizeof(pos.p->length) <\
--
   include/linux/compiler.h:260:8: sparse: attribute 'no_sanitize_address': unknown attribute
   net/sctp/input.c:1076:9: sparse: Expected , in __builtin_offset
   net/sctp/input.c:1076:9: sparse: got sctp_paramhdr_t
>> builtin:0:0: sparse: No right hand side of '+'-expression
   net/sctp/input.c:1076:9: sparse: Expected ) in 'for'
   net/sctp/input.c:1076:9: sparse: got ;
   net/sctp/input.c:1076:9: sparse: Expected ; at end of statement
   net/sctp/input.c:1076:9: sparse: got )
>> net/sctp/input.c:1081:25: sparse: break/continue not in iterator scope
   net/sctp/input.c:1090:16: sparse: Expected ) in function declarator
   net/sctp/input.c:1090:16: sparse: got (
>> net/sctp/input.c:1090:9: sparse: Trying to use reserved word 'return' as identifier
   net/sctp/input.c:1091:1: sparse: Expected ; at the end of type declaration
   net/sctp/input.c:1091:1: sparse: got }
   net/sctp/input.c:1123:13: sparse: Expected ) in function declarator
   net/sctp/input.c:1123:13: sparse: got (
>> net/sctp/input.c:1123:9: sparse: Trying to use reserved word 'if' as identifier
   net/sctp/input.c:1126:11: sparse: Expected ; at end of declaration
   net/sctp/input.c:1126:11: sparse: got ->
   net/sctp/input.c:1128:9: sparse: Trying to use reserved word 'return' as identifier
   net/sctp/input.c:1128:16: sparse: Expected ; at end of declaration
   net/sctp/input.c:1128:16: sparse: got __sctp_lookup_association
   net/sctp/input.c:1129:1: sparse: Expected ; at the end of type declaration
   net/sctp/input.c:1129:1: sparse: got }
>> net/sctp/input.c:1156:9: sparse: Trying to use reserved word 'do' as identifier
   net/sctp/input.c:1156:12: sparse: Expected ; at end of declaration
   net/sctp/input.c:1156:12: sparse: got {
   net/sctp/input.c:1162:28: sparse: Expected ) in function declarator
   net/sctp/input.c:1162:28: sparse: got >
   net/sctp/input.c:1162:17: sparse: Trying to use reserved word 'if' as identifier
   net/sctp/input.c:1165:27: sparse: Expected ) in function declarator
   net/sctp/input.c:1165:27: sparse: got ->
>> net/sctp/input.c:1165:17: sparse: Trying to use reserved word 'switch' as identifier
>> net/sctp/input.c:1168:25: sparse: Trying to use reserved word 'break' as identifier
>> net/sctp/input.c:1170:17: sparse: Trying to use reserved word 'case' as identifier
   net/sctp/input.c:1170:22: sparse: Expected ; at end of declaration
   net/sctp/input.c:1170:22: sparse: got SCTP_CID_COOKIE_ECHO
   net/sctp/input.c:1180:25: sparse: Trying to use reserved word 'break' as identifier
   net/sctp/input.c:1182:17: sparse: Trying to use reserved word 'case' as identifier
   net/sctp/input.c:1182:22: sparse: Expected ; at end of declaration
   net/sctp/input.c:1182:22: sparse: got SCTP_CID_ASCONF
>> net/sctp/input.c:1188:17: sparse: Trying to use reserved word 'default' as identifier
   net/sctp/input.c:1188:24: sparse: Expected ; at end of declaration
   net/sctp/input.c:1188:24: sparse: got :
   net/sctp/input.c:1190:17: sparse: Expected ; at the end of type declaration
   net/sctp/input.c:1190:17: sparse: got }
   net/sctp/input.c:1196:26: sparse: Expected ; at end of declaration
   net/sctp/input.c:1196:26: sparse: got ++
   net/sctp/input.c:1197:9: sparse: Expected ; at the end of type declaration
   net/sctp/input.c:1197:9: sparse: got }
   net/sctp/input.c:1199:9: sparse: Trying to use reserved word 'return' as identifier
   net/sctp/input.c:1199:16: sparse: Expected ; at end of declaration
   net/sctp/input.c:1199:16: sparse: got asoc
   net/sctp/input.c:1200:1: sparse: Expected ; at the end of type declaration
   net/sctp/input.c:1200:1: sparse: got }
   net/sctp/input.c:1220:13: sparse: Expected ) in function declarator
   net/sctp/input.c:1220:13: sparse: got (
   net/sctp/input.c:1220:9: sparse: Trying to use reserved word 'if' as identifier
   net/sctp/input.c:1230:13: sparse: Expected ) in function declarator
   net/sctp/input.c:1230:13: sparse: got (
   net/sctp/input.c:1230:9: sparse: Trying to use reserved word 'if' as identifier
   net/sctp/input.c:1234:15: sparse: Expected ) in function declarator
   net/sctp/input.c:1234:15: sparse: got ->
   net/sctp/input.c:1234:9: sparse: Trying to use reserved word 'if' as identifier
   net/sctp/input.c:1237:9: sparse: Trying to use reserved word 'return' as identifier
   net/sctp/input.c:1237:16: sparse: Expected ; at end of declaration
   net/sctp/input.c:1237:16: sparse: got __sctp_rcv_walk_lookup
   net/sctp/input.c:1238:1: sparse: Expected ; at the end of type declaration
   net/sctp/input.c:1238:1: sparse: got }
   net/sctp/input.c:1250:9: sparse: Trying to use reserved word 'if' as identifier
   net/sctp/input.c:1251:17: sparse: Expected ; at end of declaration
   net/sctp/input.c:1251:17: sparse: got goto
   net/sctp/input.c:1258:9: sparse: Trying to use reserved word 'if' as identifier
   net/sctp/input.c:1259:17: sparse: Expected ; at end of declaration
   net/sctp/input.c:1259:17: sparse: got goto
   net/sctp/input.c:1261:18: sparse: Expected ) in function declarator
   net/sctp/input.c:1261:18: sparse: got ->
   net/sctp/input.c:1261:9: sparse: Trying to use reserved word 'if' as identifier
   net/sctp/input.c:1262:17: sparse: Expected ) in function declarator
   net/sctp/input.c:1262:17: sparse: got (
   net/sctp/input.c:1262:17: sparse: Trying to use reserved word 'if' as identifier
   net/sctp/input.c:1262:17: sparse: Expected ) in function declarator
   net/sctp/input.c:1262:17: sparse: got (
   net/sctp/input.c:1262:17: sparse: Trying to use reserved word 'if' as identifier
>> net/sctp/input.c:1262:17: sparse: Trying to use reserved word 'else' as identifier
   net/sctp/input.c:1262:17: sparse: Expected ; at end of declaration
   net/sctp/input.c:1262:17: sparse: got if
>> net/sctp/input.c:1262:17: sparse: Trying to use reserved word 'else' as identifier
   net/sctp/input.c:1262:17: sparse: Expected ; at end of declaration
   net/sctp/input.c:1262:17: sparse: got branch
   net/sctp/input.c:1262:17: sparse: Expected ; at the end of type declaration
   net/sctp/input.c:1262:17: sparse: got }
   net/sctp/input.c:1262:17: sparse: Expected ; at the end of type declaration
   net/sctp/input.c:1262:17: sparse: got }
   net/sctp/input.c:1265:9: sparse: Trying to use reserved word 'else' as identifier
   net/sctp/input.c:1266:17: sparse: Expected ; at end of declaration
   net/sctp/input.c:1266:17: sparse: got do
   net/sctp/input.c:1266:17: sparse: Expected ) in function declarator
   net/sctp/input.c:1266:17: sparse: got (
   net/sctp/input.c:1266:17: sparse: Trying to use reserved word 'if' as identifier
   net/sctp/input.c:1266:17: sparse: Expected ) in function declarator
>> net/sctp/input.c:1266:17: sparse: too many errors
   In file included from include/linux/compiler.h:58:0,
                    from include/uapi/linux/stddef.h:1,
                    from include/linux/stddef.h:4,
                    from include/uapi/linux/posix_types.h:4,
                    from include/uapi/linux/types.h:13,
                    from include/linux/types.h:5,
                    from net/sctp/input.c:44:
   net/sctp/input.c: In function '__sctp_rcv_init_lookup':
   include/net/sctp/sctp.h:472:24: error: unknown type name 'sctp_paramhdr_t'
         (pos.v + offsetof(sctp_paramhdr_t, length) + sizeof(pos.p->length) <\
                           ^
   include/linux/compiler-gcc.h:161:21: note: in definition of macro '__compiler_offsetof'
     __builtin_offsetof(a, b)
                        ^
   include/net/sctp/sctp.h:472:15: note: in expansion of macro 'offsetof'
         (pos.v + offsetof(sctp_paramhdr_t, length) + sizeof(pos.p->length) <\
                  ^~~~~~~~
   include/net/sctp/sctp.h:468:1: note: in expansion of macro '_sctp_walk_params'
    _sctp_walk_params((pos), (chunk), ntohs((chunk)->chunk_hdr.length), member)
    ^~~~~~~~~~~~~~~~~
   net/sctp/input.c:1076:2: note: in expansion of macro 'sctp_walk_params'
     sctp_walk_params(params, init, init_hdr.params) {
     ^~~~~~~~~~~~~~~~
--
   include/linux/compiler.h:260:8: sparse: attribute 'no_sanitize_address': unknown attribute
   net/sctp/stream.c:319:9: sparse: Expected , in __builtin_offset
   net/sctp/stream.c:319:9: sparse: got sctp_paramhdr_t
>> builtin:0:0: sparse: No right hand side of '+'-expression
   net/sctp/stream.c:319:9: sparse: Expected ) in 'for'
   net/sctp/stream.c:319:9: sparse: got ;
   net/sctp/stream.c:319:9: sparse: Expected ; at end of statement
   net/sctp/stream.c:319:9: sparse: got )
   net/sctp/stream.c:331:16: sparse: Expected ) in function declarator
   net/sctp/stream.c:331:16: sparse: got (
>> net/sctp/stream.c:331:9: sparse: Trying to use reserved word 'return' as identifier
   net/sctp/stream.c:332:1: sparse: Expected ; at the end of type declaration
   net/sctp/stream.c:332:1: sparse: got }
   net/sctp/stream.c:338:13: sparse: Expected ; at end of declaration
   net/sctp/stream.c:338:13: sparse: got ->
   net/sctp/stream.c:339:1: sparse: Expected ; at the end of type declaration
   net/sctp/stream.c:339:1: sparse: got }
   net/sctp/stream.c:354:13: sparse: Expected ) in function declarator
   net/sctp/stream.c:354:13: sparse: got (
>> net/sctp/stream.c:354:9: sparse: Trying to use reserved word 'if' as identifier
>> net/sctp/stream.c:357:17: sparse: Trying to use reserved word 'goto' as identifier
   net/sctp/stream.c:357:22: sparse: Expected ; at end of declaration
   net/sctp/stream.c:357:22: sparse: got err
   net/sctp/stream.c:358:9: sparse: Expected ; at the end of type declaration
   net/sctp/stream.c:358:9: sparse: got }
   net/sctp/stream.c:360:13: sparse: Expected ) in function declarator
   net/sctp/stream.c:360:13: sparse: got &
>> net/sctp/stream.c:360:13: sparse: Trying to use reserved word 'void' as identifier
   net/sctp/stream.c:360:13: sparse: Expected ; at the end of type declaration
   net/sctp/stream.c:360:13: sparse: got 1
   net/sctp/stream.c:360:13: sparse: Expected ; at the end of type declaration
   net/sctp/stream.c:360:13: sparse: got }
   net/sctp/stream.c:360:13: sparse: Expected ) in function declarator
   net/sctp/stream.c:360:13: sparse: got &
>> net/sctp/stream.c:360:13: sparse: Trying to use reserved word 'void' as identifier
   net/sctp/stream.c:360:13: sparse: Expected ; at the end of type declaration
   net/sctp/stream.c:360:13: sparse: got 1
   net/sctp/stream.c:360:13: sparse: Expected ; at the end of type declaration
   net/sctp/stream.c:360:13: sparse: got }
   net/sctp/stream.c:361:13: sparse: Expected ) in function declarator
   net/sctp/stream.c:361:13: sparse: got &
   net/sctp/stream.c:361:13: sparse: Trying to use reserved word 'void' as identifier
   net/sctp/stream.c:361:13: sparse: Expected ; at the end of type declaration
   net/sctp/stream.c:361:13: sparse: got 1
   net/sctp/stream.c:361:13: sparse: Expected ; at the end of type declaration
   net/sctp/stream.c:361:13: sparse: got }
   net/sctp/stream.c:361:13: sparse: Expected ) in function declarator
   net/sctp/stream.c:361:13: sparse: got &
   net/sctp/stream.c:361:13: sparse: Trying to use reserved word 'void' as identifier
   net/sctp/stream.c:361:13: sparse: Expected ; at the end of type declaration
   net/sctp/stream.c:361:13: sparse: got 1
   net/sctp/stream.c:361:13: sparse: Expected ; at the end of type declaration
   net/sctp/stream.c:361:13: sparse: got }
   net/sctp/stream.c:363:17: sparse: Trying to use reserved word 'goto' as identifier
   net/sctp/stream.c:363:22: sparse: Expected ; at end of declaration
   net/sctp/stream.c:363:22: sparse: got err
   net/sctp/stream.c:364:9: sparse: Expected ; at the end of type declaration
   net/sctp/stream.c:364:9: sparse: got }
   net/sctp/stream.c:364:20: sparse: Expected ) in function declarator
   net/sctp/stream.c:364:20: sparse: got &
   net/sctp/stream.c:364:20: sparse: Trying to use reserved word 'void' as identifier
   net/sctp/stream.c:364:20: sparse: Expected ; at the end of type declaration
   net/sctp/stream.c:364:20: sparse: got 1
   net/sctp/stream.c:364:20: sparse: Expected ; at the end of type declaration
   net/sctp/stream.c:364:20: sparse: got }
   net/sctp/stream.c:364:20: sparse: Expected ) in function declarator
   net/sctp/stream.c:364:20: sparse: got &
   net/sctp/stream.c:364:20: sparse: Trying to use reserved word 'void' as identifier
   net/sctp/stream.c:364:20: sparse: Expected ; at the end of type declaration
   net/sctp/stream.c:364:20: sparse: got 1
   net/sctp/stream.c:364:20: sparse: Expected ; at the end of type declaration
   net/sctp/stream.c:364:20: sparse: got }
   net/sctp/stream.c:367:17: sparse: Trying to use reserved word 'goto' as identifier
   net/sctp/stream.c:367:22: sparse: Expected ; at end of declaration
   net/sctp/stream.c:367:22: sparse: got err
   net/sctp/stream.c:368:9: sparse: Expected ; at the end of type declaration
   net/sctp/stream.c:368:9: sparse: got }
   net/sctp/stream.c:375:13: sparse: Expected ) in function declarator
   net/sctp/stream.c:375:13: sparse: got !
   net/sctp/stream.c:375:9: sparse: Trying to use reserved word 'if' as identifier
   net/sctp/stream.c:378:17: sparse: Expected ) in function declarator
   net/sctp/stream.c:378:17: sparse: got ->
   net/sctp/stream.c:378:9: sparse: Trying to use reserved word 'if' as identifier
   net/sctp/stream.c:384:25: sparse: Trying to use reserved word 'goto' as identifier
   net/sctp/stream.c:384:30: sparse: Expected ; at end of declaration
   net/sctp/stream.c:384:30: sparse: got out
   net/sctp/stream.c:385:17: sparse: Expected ; at the end of type declaration
   net/sctp/stream.c:385:17: sparse: got }
   net/sctp/stream.c:388:21: sparse: Expected ; at end of declaration
   net/sctp/stream.c:388:21: sparse: got ->
   net/sctp/stream.c:390:21: sparse: Expected ) in function declarator
   net/sctp/stream.c:390:21: sparse: got !
   net/sctp/stream.c:390:17: sparse: Trying to use reserved word 'if' as identifier
   net/sctp/stream.c:394:38: sparse: Expected ) in function declarator
   net/sctp/stream.c:394:38: sparse: got (
   net/sctp/stream.c:394:25: sparse: Trying to use reserved word 'if' as identifier
   net/sctp/stream.c:397:44: sparse: Expected ) in function declarator
   net/sctp/stream.c:397:44: sparse: got ->
   net/sctp/stream.c:398:29: sparse: Expected ; at end of declaration
   net/sctp/stream.c:398:29: sparse: got ->
   net/sctp/stream.c:399:17: sparse: Expected ; at the end of type declaration
>> net/sctp/stream.c:399:17: sparse: too many errors
   In file included from include/linux/compiler.h:58:0,
                    from include/uapi/linux/stddef.h:1,
                    from include/linux/stddef.h:4,
                    from include/uapi/linux/posix_types.h:4,
                    from include/uapi/linux/types.h:13,
                    from include/linux/types.h:5,
                    from include/net/sctp/sctp.h:58,
                    from net/sctp/stream.c:35:
   net/sctp/stream.c: In function 'sctp_chunk_lookup_strreset_param':
   include/net/sctp/sctp.h:472:24: error: unknown type name 'sctp_paramhdr_t'
         (pos.v + offsetof(sctp_paramhdr_t, length) + sizeof(pos.p->length) <\
                           ^
   include/linux/compiler-gcc.h:161:21: note: in definition of macro '__compiler_offsetof'
     __builtin_offsetof(a, b)
                        ^
   include/net/sctp/sctp.h:472:15: note: in expansion of macro 'offsetof'
         (pos.v + offsetof(sctp_paramhdr_t, length) + sizeof(pos.p->length) <\
                  ^~~~~~~~
   include/net/sctp/sctp.h:468:1: note: in expansion of macro '_sctp_walk_params'
    _sctp_walk_params((pos), (chunk), ntohs((chunk)->chunk_hdr.length), member)
    ^~~~~~~~~~~~~~~~~
   net/sctp/stream.c:319:2: note: in expansion of macro 'sctp_walk_params'
     sctp_walk_params(param, hdr, params) {
     ^~~~~~~~~~~~~~~~

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
